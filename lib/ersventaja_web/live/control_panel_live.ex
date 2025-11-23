defmodule ErsventajaWeb.ControlPanelLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Navbar
  import ErsventajaWeb.Components.Hero
  import ErsventajaWeb.Components.Toast

  alias Ersventaja.Policies
  alias Ersventaja.UserManager.Guardian

  @impl true
  def mount(_params, session, socket) do
    token = Map.get(session, "guardian_default_token")
    case token && Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        policies = Policies.last_30_days()
        insurers = Policies.get_insurers()

        socket =
          socket
          |> assign(current_user: user)
          |> assign(active_tab: "due")
          |> assign(policies: policies)
          |> assign(insurers: insurers)
          |> assign(query_current: "")
          |> assign(query_current_result: [])
          |> assign(query: "")
          |> assign(query_result: [])
          |> assign(insert_form: %{name: "", insurer_id: "", detail: "", start_date: "", end_date: "", encoded_file: nil})
          |> assign(adding_policy: false)
          |> assign(new_insurer_name: "")
          |> assign(file_selected_shown: false)
          |> allow_upload(:file, accept: ~w(.pdf), max_entries: 1, max_file_size: 10_000_000)

        {:ok, socket}

      _ ->
        {:ok, redirect(socket, to: "/login")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    tab = Map.get(params, "tab", "due")
    socket = assign(socket, active_tab: tab)

    # Refresh insurers list when switching to insurers tab
    socket = if tab == "insurers" do
      assign(socket, insurers: Policies.get_insurers())
    else
      socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: "/controlpanel?tab=#{tab}")}
  end

  @impl true
  def handle_event("update_renewal", %{"id" => id} = params, socket) do
    # Get the current policy to toggle its calculated status
    policy = Enum.find(socket.assigns.policies, fn p -> Integer.to_string(p.id) == id end)

    # Determine new status: if checkbox sends "value" => "on", it means it's being checked
    # Otherwise, toggle based on current state
    new_status = case params do
      %{"value" => "on"} -> true
      %{"value" => _} -> false
      _ -> if policy, do: !policy.calculated, else: false
    end

    Policies.update_status(id, new_status)
    policies = Policies.last_30_days()
    {:noreply, assign(socket, policies: policies)}
  end

  @impl true
  def handle_event("query_current", %{"query" => query}, socket) do
    if String.length(query) > 0 do
      result = Policies.get_policies("true", query)
      {:noreply, assign(socket, query_current_result: result, query_current: "")}
    else
      {:noreply, socket |> put_flash(:warning, "Favor preencher o nome para realizar a busca.")}
    end
  end

  @impl true
  def handle_event("query_all", %{"query" => query}, socket) do
    if String.length(query) > 0 do
      result = Policies.get_policies("false", query)
      {:noreply, assign(socket, query_result: result, query: "")}
    else
      {:noreply, socket |> put_flash(:warning, "Favor preencher o nome para realizar a busca.")}
    end
  end

  @impl true
  def handle_event("delete_policy", %{"id" => id}, socket) do
    Policies.delete_policy(id)
    query_result = Enum.reject(socket.assigns.query_result, fn p -> p.id == String.to_integer(id) end)
    {:noreply, assign(socket, query_result: query_result)}
  end

  @impl true
  def handle_event("validate_insert", %{"insert_form" => form_params}, socket) do
    insert_form = Map.merge(socket.assigns.insert_form, form_params)
    {:noreply, assign(socket, insert_form: insert_form)}
  end

  @impl true
  def handle_event("insert_policy", %{"insert_form" => form_params}, socket) do
    socket = assign(socket, adding_policy: true)

    if valid_insert_form?(form_params, socket) do
      # Consume uploaded file
      [file] = consume_uploaded_entries(socket, :file, fn %{path: path}, _entry ->
        content = File.read!(path)
        encoded = Base.encode64(content)
        {:ok, encoded}
      end)

      attrs = %{
        "name" => String.upcase(form_params["name"]),
        "detail" => String.upcase(form_params["detail"]),
        "start_date" => form_params["start_date"],
        "end_date" => form_params["end_date"],
        "insurer_id" => String.to_integer(form_params["insurer_id"]),
        "encoded_file" => file
      }

      Policies.add_policy(attrs)
      policies = Policies.last_30_days()

      socket =
        socket
        |> put_flash(:success, "Cadastro realizado com sucesso!")
        |> assign(
          policies: policies,
          insert_form: %{name: "", insurer_id: "", detail: "", start_date: "", end_date: "", encoded_file: nil},
          adding_policy: false
        )

      {:noreply, socket}
    else
      {:noreply, socket |> put_flash(:warning, "Favor preencher todos os campos antes de prosseguir!") |> assign(adding_policy: false)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :file, ref)}
  end

  @impl true
  def handle_event("file_selected", _params, socket) do
    {:noreply, put_flash(socket, :info, "Arquivo selecionado")}
  end

  @impl true
  def handle_event("create_insurer", %{"name" => name}, socket) do
    if String.trim(name) != "" do
      try do
        Policies.add_insurer(String.trim(name))
        insurers = Policies.get_insurers()
        {:noreply, socket |> put_flash(:success, "Operação realizada com sucesso!") |> assign(insurers: insurers, new_insurer_name: "")}
      rescue
        _ ->
          {:noreply, socket |> put_flash(:error, "Erro ao realizar a operação. Verifique se a seguradora não está sendo usada em alguma apólice.")}
      end
    else
      {:noreply, socket |> put_flash(:error, "Erro ao realizar a operação. Verifique se a seguradora não está sendo usada em alguma apólice.")}
    end
  end

  @impl true
  def handle_event("update_insurer_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, new_insurer_name: name)}
  end

  @impl true
  def handle_event("delete_insurer", %{"id" => id}, socket) do
    try do
      Policies.delete_insurer(String.to_integer(id))
      insurers = Policies.get_insurers()
      {:noreply, socket |> put_flash(:success, "Operação realizada com sucesso!") |> assign(insurers: insurers)}
    rescue
      _ ->
        {:noreply, socket |> put_flash(:error, "Erro ao realizar a operação. Verifique se a seguradora não está sendo usada em alguma apólice.")}
    end
  end

  defp valid_insert_form?(form, socket) do
    String.length(form["name"] || "") > 0 &&
      String.length(form["detail"] || "") > 0 &&
      String.length(form["insurer_id"] || "") > 0 &&
      String.length(form["start_date"] || "") > 0 &&
      String.length(form["end_date"] || "") > 0 &&
      Enum.any?(socket.assigns.uploads.file.entries)
  end

  defp calculate_days(end_date) when is_binary(end_date) do
    today = Date.utc_today()
    end_date = Date.from_iso8601!(end_date)
    Date.diff(end_date, today)
  end

  defp calculate_days(%Date{} = end_date) do
    today = Date.utc_today()
    Date.diff(end_date, today)
  end

  defp file_url(file_name) do
    "https://policiesrsventaja.s3-sa-east-1.amazonaws.com/#{file_name}"
  end

  defp format_date(date) when is_binary(date) do
    date
    |> Date.from_iso8601!()
    |> format_date()
  end

  defp format_date(%Date{} = date) do
    Calendar.strftime(date, "%d/%m/%Y")
  end

  defp error_to_string(:too_large), do: "Arquivo muito grande"
  defp error_to_string(:too_many_files), do: "Muitos arquivos"
  defp error_to_string(:not_accepted), do: "Tipo de arquivo não aceito"

  @impl true
  def render(assigns) do
    ~H"""
    <.toast flash={@flash} />
    <style>
      body { margin: 0; padding: 0; font-family: 'Playfair Display', Georgia, serif; color: #504f4f; }

      /* Main Content */
      .main-content { padding-top: 0; background-color: white; min-height: 100vh; }
      .section { padding: 3em 2em; text-align: center; width: 100%; max-width: 100%; }

      /* Tabs */
      .tab-button { padding: 1em 1.5em; font-size: 16px; font-weight: 500; border: none; background: transparent; cursor: pointer; transition: all 0.2s; font-family: 'Playfair Display', Georgia, serif; display: flex; align-items: center; justify-content: center; gap: 0.5em; }
      .tab-button.active { background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%); color: white; border-radius: 4px; }
      .tab-button:not(.active) { color: #666; }
      .tab-button:not(.active):hover { background-color: rgba(61, 95, 163, 0.1); border-radius: 4px; }
      .tab-button i { margin: 0; }

      /* Buttons */
      .btn-primary { background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%); color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 0.5em; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: all 0.2s; font-family: 'Playfair Display', Georgia, serif; font-size: 16px; }
      .btn-primary:hover { background: rgba(255, 255, 255, 0.85); color: #1e3a6e; font-weight: 600; border: 1px solid #7DCDEB; }
      .btn-primary i { margin: 0; }

      /* Tables */
      .table-container { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 2em; margin: 2em 0; }
      .table-container table { width: 100%; border-collapse: collapse; }
      .table-container th { padding: 1em; text-align: left; font-size: 14px; font-weight: 600; color: #504f4f; border-bottom: 2px solid #e5e7eb; font-family: 'Playfair Display', Georgia, serif; }
      .table-container td { padding: 1em; font-size: 15px; color: #504f4f; border-bottom: 1px solid #f3f4f6; font-family: 'Playfair Display', Georgia, serif; }
      .table-container tr:hover { background-color: #f9fafb; }

      /* Forms - Override Tailwind and browser defaults */
      input, select, textarea {
        border-radius: 8px !important;
        border: 2px solid #e5e7eb !important;
      }

      .form-input {
        width: 100% !important;
        padding: 12px !important;
        border: 2px solid #e5e7eb !important;
        border-radius: 8px !important;
        font-size: 15px !important;
        font-family: 'Playfair Display', Georgia, serif !important;
        box-sizing: border-box !important;
        height: 44px !important;
        line-height: 1.5 !important;
        transition: all 0.2s ease !important;
        background-color: white !important;
        -webkit-appearance: none !important;
        -moz-appearance: none !important;
        appearance: none !important;
      }
      .form-input:focus {
        outline: none !important;
        border-color: #4A7AC2 !important;
        box-shadow: 0 0 0 3px rgba(74, 122, 194, 0.1) !important;
      }
      .form-input:hover {
        border-color: #cbd5e1 !important;
      }

      select.form-input {
        width: 100% !important;
        min-width: 0 !important;
        height: 44px !important;
        padding: 12px 40px 12px 12px !important;
        overflow: visible !important;
        text-overflow: clip !important;
        white-space: normal !important;
        word-wrap: break-word !important;
        background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 8" width="30"><path fill="%234A7AC2" d="M0,0l6,8l6-8"/></svg>') center right no-repeat !important;
        background-size: 20px !important;
        background-position: right 12px center !important;
        cursor: pointer !important;
      }
      select.form-input:hover {
        border-color: #cbd5e1 !important;
      }
      select.form-input:focus {
        border-color: #4A7AC2 !important;
        box-shadow: 0 0 0 3px rgba(74, 122, 194, 0.1) !important;
      }
      select.form-input option {
        white-space: normal !important;
        padding: 12px !important;
        border-radius: 4px !important;
        background: white !important;
      }

      input[type="date"].form-input {
        cursor: pointer !important;
        position: relative !important;
      }
      input[type="date"].form-input::-webkit-calendar-picker-indicator {
        cursor: pointer !important;
        opacity: 1 !important;
        width: 20px !important;
        height: 20px !important;
        padding: 4px !important;
        margin-left: 8px !important;
        filter: invert(0.5) sepia(1) saturate(5) hue-rotate(200deg) !important;
      }
      input[type="date"].form-input::-webkit-inner-spin-button,
      input[type="date"].form-input::-webkit-clear-button {
        display: none !important;
      }

      /* File input styling */
      input[type="file"].form-input {
        font-size: 15px !important;
        padding: 12px !important;
        cursor: pointer !important;
        width: 100% !important;
        max-width: 100% !important;
        min-width: 0 !important;
        box-sizing: border-box !important;
        display: block !important;
        height: auto !important;
        min-height: 44px !important;
      }
      input[type="file"].form-input::file-selector-button {
        font-size: 14px !important;
        font-family: 'Playfair Display', Georgia, serif !important;
        padding: 10px 16px !important;
        margin-right: 10px !important;
        border-radius: 8px !important;
        border: none !important;
        background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%) !important;
        color: white !important;
        font-weight: 500 !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        white-space: nowrap !important;
        flex-shrink: 1 !important;
      }
      /* Hide the default file name text to prevent overflow */
      input[type="file"].form-input::after {
        content: "" !important;
        display: none !important;
      }
      input[type="file"].form-input::file-selector-button:hover {
        background: rgba(255, 255, 255, 0.3) !important;
        color: #1e3a6e !important;
        font-weight: 600 !important;
        border: 1px solid #7DCDEB !important;
      }
      input[type="file"].form-input::-webkit-file-upload-button {
        font-size: 14px !important;
        font-family: 'Playfair Display', Georgia, serif !important;
        padding: 10px 16px !important;
        margin-right: 10px !important;
        border-radius: 8px !important;
        border: none !important;
        background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%) !important;
        color: white !important;
        font-weight: 500 !important;
        cursor: pointer !important;
        transition: all 0.2s ease !important;
        white-space: nowrap !important;
      }
      input[type="file"].form-input::-webkit-file-upload-button:hover {
        background: rgba(255, 255, 255, 0.3) !important;
        color: #1e3a6e !important;
        font-weight: 600 !important;
        border: 1px solid #7DCDEB !important;
      }
      /* Hide the default file name text that appears after the button */
      input[type="file"].form-input::after {
        content: "" !important;
      }
    </style>

    <div class="min-h-screen bg-gray-50">
      <.navbar />
      <.hero title="Painel de Controle" subtitle="Gerenciamento de Apólices" />

      <!-- Main Content -->
      <div class="main-content" style="max-width: 1400px; margin: 0 auto; padding: 3em 2em;">
        <!-- Tabs -->
        <div class="bg-white rounded-lg shadow-md mb-6 p-4">
          <nav class="flex flex-wrap gap-2">
            <button
              phx-click="switch_tab"
              phx-value-tab="due"
              class={"tab-button #{if @active_tab == "due", do: "active", else: ""}"}
            >
              <i class="fas fa-clock"></i>
              Apólices a vencer
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="current"
              class={"tab-button #{if @active_tab == "current", do: "active", else: ""}"}
            >
              <i class="fas fa-search"></i>
              Buscar apólices vigentes
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="all"
              class={"tab-button #{if @active_tab == "all", do: "active", else: ""}"}
            >
              <i class="fas fa-list"></i>
              Buscar apólices
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="register"
              class={"tab-button #{if @active_tab == "register", do: "active", else: ""}"}
            >
              <i class="fas fa-plus-circle"></i>
              Cadastrar apólice
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="insurers"
              class={"tab-button #{if @active_tab == "insurers", do: "active", else: ""}"}
            >
              <i class="fas fa-building"></i>
              Configurar seguradoras
            </button>
          </nav>
        </div>

        <%= if @active_tab == "due" do %>
          <div class="table-container">
            <h2 style="font-size: 28px; font-weight: 500; margin-bottom: 1.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Apólices com vencimento nos próximos 30 dias</h2>
            <div class="overflow-x-auto">
              <table>
                <thead>
                  <tr>
                    <th>Calculado?</th>
                    <th>Dias Restantes</th>
                    <th>Nome</th>
                    <th>Seguradora</th>
                    <th>Informações Adicionais</th>
                    <th>Início</th>
                    <th>Vencimento</th>
                    <th>Ação</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for policy <- @policies do %>
                    <tr id={"policy-due-#{policy.id}"}>
                      <td>
                        <input
                          type="checkbox"
                          checked={policy.calculated}
                          phx-click="update_renewal"
                          phx-value-id={policy.id}
                          style="width: 20px; height: 20px; cursor: pointer;"
                        />
                      </td>
                      <td>
                        <span style={"padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; #{if calculate_days(policy.end_date) <= 7, do: "background-color: #fee2e2; color: #991b1b;", else: "background-color: #fef3c7; color: #92400e;"}"}>
                          <%= calculate_days(policy.end_date) %> dias
                        </span>
                      </td>
                      <td style="font-weight: 500;"><%= policy.customer_name %></td>
                      <td><%= policy.insurer %></td>
                      <td><%= policy.detail %></td>
                      <td><%= format_date(policy.start_date) %></td>
                      <td><%= format_date(policy.end_date) %></td>
                      <td>
                        <a
                          href={file_url(policy.file_name)}
                          target="_blank"
                          rel="noopener noreferrer"
                          style="color: #3D5FA3; text-decoration: none; font-weight: 500;"
                        >
                          <i class="fas fa-file-pdf"></i> Abrir
                        </a>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        <% end %>

        <%= if @active_tab == "current" do %>
          <div class="table-container">

            <h2 style="font-size: 28px; font-weight: 500; margin-bottom: 1.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Buscar apólices vigentes</h2>

            <form phx-submit="query_current" style="margin-bottom: 2em;">
              <div style="max-width: 600px;">
                <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">
                  Digite parte ou o nome do cliente
                </label>
                <div style="display: flex; gap: 0.75em;">
                  <input
                    type="text"
                    name="query"
                    value={@query_current}
                    class="form-input"
                    placeholder="Nome do cliente..."
                  />
                  <button
                    type="submit"
                    class="btn-primary"
                  >
                    <i class="fas fa-search"></i>
                    <span>Buscar</span>
                  </button>
                </div>
              </div>
            </form>

            <%= if length(@query_current_result) > 0 do %>
              <div class="overflow-x-auto">
                <table>
                  <thead>
                    <tr>
                      <th>Dias Restantes</th>
                      <th>Nome</th>
                      <th>Seguradora</th>
                      <th>Informações Adicionais</th>
                      <th>Início</th>
                      <th>Vencimento</th>
                      <th>Ação</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for policy <- @query_current_result do %>
                      <tr id={"policy-current-#{policy.id}"}>
                        <td>
                          <span style="padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: 600; background-color: #d1fae5; color: #065f46;">
                            <%= calculate_days(policy.end_date) %> dias
                          </span>
                        </td>
                        <td style="font-weight: 500;"><%= policy.customer_name %></td>
                        <td><%= policy.insurer %></td>
                        <td><%= policy.detail %></td>
                        <td><%= format_date(policy.start_date) %></td>
                        <td><%= format_date(policy.end_date) %></td>
                        <td>
                          <a href={file_url(policy.file_name)} target="_blank" rel="noopener noreferrer" style="color: #3D5FA3; text-decoration: none; font-weight: 500;">
                            <i class="fas fa-file-pdf"></i> Abrir
                          </a>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if @active_tab == "all" do %>
          <div class="table-container">

            <h2 style="font-size: 28px; font-weight: 500; margin-bottom: 1.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Buscar apólices</h2>

            <form phx-submit="query_all" style="margin-bottom: 2em;">
              <div style="max-width: 600px;">
                <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">
                  Digite parte ou o nome do cliente
                </label>
                <div style="display: flex; gap: 0.75em;">
                  <input
                    type="text"
                    name="query"
                    value={@query}
                    class="form-input"
                    placeholder="Nome do cliente..."
                  />
                  <button
                    type="submit"
                    class="btn-primary"
                  >
                    <i class="fas fa-search"></i>
                    <span>Buscar</span>
                  </button>
                </div>
              </div>
            </form>

            <%= if length(@query_result) > 0 do %>
              <div class="overflow-x-auto">
                <table>
                  <thead>
                    <tr>
                      <th>Nome</th>
                      <th>Seguradora</th>
                      <th>Informações Adicionais</th>
                      <th>Início</th>
                      <th>Vencimento</th>
                      <th>Ações</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for policy <- @query_result do %>
                      <tr id={"policy-all-#{policy.id}"}>
                        <td style="font-weight: 500;"><%= policy.customer_name %></td>
                        <td><%= policy.insurer %></td>
                        <td><%= policy.detail %></td>
                        <td><%= format_date(policy.start_date) %></td>
                        <td><%= format_date(policy.end_date) %></td>
                        <td>
                          <div style="display: flex; gap: 1em;">
                            <a href={file_url(policy.file_name)} target="_blank" rel="noopener noreferrer" style="color: #3D5FA3; text-decoration: none; font-weight: 500;">
                              <i class="fas fa-file-pdf"></i> Abrir
                            </a>
                            <button phx-click="delete_policy" phx-value-id={policy.id} style="color: #dc2626; background: none; border: none; cursor: pointer; font-weight: 500; font-family: 'Playfair Display', Georgia, serif;">
                              <i class="fas fa-trash-alt"></i> Excluir
                            </button>
                          </div>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if @active_tab == "register" do %>
          <div class="table-container">

            <h2 style="font-size: 28px; font-weight: 500; margin-bottom: 1.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Cadastrar apólice</h2>

            <%= if @adding_policy do %>
              <div class="flex justify-center items-center py-8">
                <div class="flex items-center space-x-3">
                  <i class="fas fa-spinner fa-spin text-brand-blue text-2xl"></i>
                  <span class="text-lg text-gray-600">Processando...</span>
                </div>
              </div>
            <% end %>

            <form phx-submit="insert_policy" phx-change="validate_insert" enctype="multipart/form-data" class="space-y-6">
              <input type="hidden" name="insert_form[encoded_file]" value={@insert_form["encoded_file"] || ""} />

              <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5em; margin-bottom: 1.5em;">
                <div style="min-width: 0;">
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">Nome do proponente</label>
                  <input
                    type="text"
                    name="insert_form[name]"
                    value={@insert_form["name"]}
                    class="form-input"
                    placeholder="Nome completo"
                  />
                </div>

                <div style="min-width: 0;">
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">Seguradora</label>
                  <select
                    name="insert_form[insurer_id]"
                    class="form-input"
                  >
                    <option value="">Selecione uma seguradora</option>
                    <%= for insurer <- @insurers do %>
                      <option value={insurer.id} id={"insurer-option-#{insurer.id}"} selected={@insert_form["insurer_id"] == to_string(insurer.id)}>
                        <%= insurer.name %>
                      </option>
                    <% end %>
                  </select>
                </div>

                <div style="grid-column: span 2;">
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">Informações adicionais</label>
                  <input
                    type="text"
                    name="insert_form[detail]"
                    maxlength="50"
                    value={@insert_form["detail"]}
                    class="form-input"
                    placeholder="Detalhes da apólice"
                  />
                </div>

                <div>
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">Data de início de vigência</label>
                  <input
                    type="date"
                    name="insert_form[start_date]"
                    value={@insert_form["start_date"]}
                    class="form-input"
                  />
                </div>

                <div>
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">Data de fim de vigência</label>
                  <input
                    type="date"
                    name="insert_form[end_date]"
                    value={@insert_form["end_date"]}
                    class="form-input"
                  />
                </div>

                <div class="md:col-span-2" style="min-width: 0; width: 100%; grid-column: 1 / -1;">
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Arquivo PDF</label>
                  <div style="position: relative; width: 100%; min-width: 0;">
                    <.live_file_input
                      upload={@uploads.file}
                      class="form-input"
                      style="font-size: 15px !important; padding: 12px !important; cursor: pointer !important; width: 100% !important; max-width: 100% !important; box-sizing: border-box !important; min-width: 0 !important;"
                      phx-hook="FileSelect"
                    />
                  </div>
                    <%= for {err, idx} <- Enum.with_index(upload_errors(@uploads.file)) do %>
                      <div class="mt-3 bg-red-50 border-l-4 border-red-400 p-3 rounded" id={"upload-error-#{idx}"}>
                        <p class="text-base text-red-700 font-serif"><%= error_to_string(err) %></p>
                      </div>
                    <% end %>
                </div>
              </div>

              <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 1em;">
                <button
                  type="submit"
                  class="btn-primary"
                  style={if @adding_policy, do: "opacity: 0.5; cursor: not-allowed;", else: ""}
                  disabled={@adding_policy}
                >
                  <i class="fas fa-plus-circle"></i>
                  <span>Cadastrar Apólice</span>
                </button>
                <%= if @adding_policy and length(@uploads.file.entries) > 0 do %>
                  <%= for entry <- @uploads.file.entries do %>
                    <div style="width: 100%; max-width: 300px; display: flex; flex-direction: column; gap: 0.5em; margin-top: 0.5em;">
                      <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 14px; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Enviando arquivo...</span>
                        <span style="font-size: 14px; color: #504f4f; font-family: 'Playfair Display', Georgia, serif; font-weight: 500;"><%= entry.progress %>%</span>
                      </div>
                      <div style="width: 100%; height: 8px; background-color: #e5e7eb; border-radius: 4px; overflow: hidden;">
                        <div style={"height: 100%; background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%); border-radius: 4px; transition: width 0.3s ease; width: #{entry.progress}%"}></div>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </form>
          </div>
        <% end %>

        <%= if @active_tab == "insurers" do %>
          <div class="table-container">

            <h2 style="font-size: 28px; font-weight: 500; margin-bottom: 1.5em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Configurar Seguradoras</h2>

            <!-- Create New Insurer -->
            <div style="margin-bottom: 3em; padding: 2em; background-color: #f9fafb; border-radius: 8px;">
              <h3 style="font-size: 20px; font-weight: 500; margin-bottom: 1em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Adicionar Nova Seguradora</h3>
              <form phx-submit="create_insurer" phx-change="update_insurer_name" style="display: flex; gap: 0.75em; align-items: flex-end;">
                <div style="flex: 1;">
                  <label style="display: block; font-size: 15px; font-weight: 500; margin-bottom: 0.5em; color: #504f4f;">
                    Nome da Seguradora
                  </label>
                  <input
                    type="text"
                    name="name"
                    value={@new_insurer_name}
                    class="form-input"
                    placeholder="Digite o nome da seguradora..."
                    required
                  />
                </div>
                <button
                  type="submit"
                  class="btn-primary"
                  style="height: 44px;"
                >
                  <i class="fas fa-plus"></i>
                  <span>Adicionar</span>
                </button>
              </form>
            </div>

            <!-- List of Insurers -->
            <div>
              <h3 style="font-size: 20px; font-weight: 500; margin-bottom: 1em; color: #504f4f; font-family: 'Playfair Display', Georgia, serif;">Seguradoras Cadastradas</h3>
              <%= if length(@insurers) > 0 do %>
                <div class="overflow-x-auto">
                  <table>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Nome</th>
                        <th>Ações</th>
                      </tr>
                    </thead>
                    <tbody>
                      <%= for insurer <- @insurers do %>
                        <tr id={"insurer-row-#{insurer.id}"}>
                          <td style="font-weight: 500;"><%= insurer.id %></td>
                          <td style="font-weight: 500;"><%= insurer.name %></td>
                          <td>
                            <button
                              phx-click="delete_insurer"
                              phx-value-id={insurer.id}
                              style="color: #dc2626; background: none; border: none; cursor: pointer; font-weight: 500; font-family: 'Playfair Display', Georgia, serif; padding: 0.5em 1em; border-radius: 4px; transition: all 0.2s;"
                              onmouseover="this.style.backgroundColor='#fee2e2'"
                              onmouseout="this.style.backgroundColor='transparent'"
                            >
                              <i class="fas fa-trash-alt"></i> Excluir
                            </button>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              <% else %>
                <p style="text-align: center; color: #666; padding: 2em; font-family: 'Playfair Display', Georgia, serif;">Nenhuma seguradora cadastrada ainda.</p>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
