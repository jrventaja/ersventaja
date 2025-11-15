# Cost-Equivalent Deployment Improvements

These improvements keep your costs the same (<$10/month) but make deployment easier and more reliable.

## 🎯 **SIMPLEST OPTION: No Nginx, No Apache (RECOMMENDED)**

**File: `docker-compose-no-nginx.yml`**

If you're using **Cloudflare for SSL**, you don't need nginx at all! Phoenix can serve everything directly:
- ✅ **Phoenix serves API** (`/api/*`)
- ✅ **Phoenix serves Angular app** (static files from `html/`)
- ✅ **Phoenix handles routing** (catch-all for SPA routes)
- ✅ **Cloudflare handles SSL** (free)

### Setup:
```bash
# Use the simplified compose file
docker compose -f docker-compose-no-nginx.yml up -d

# That's it! Phoenix is now on port 80, Cloudflare handles SSL
```

### What changed:
1. **Removed nginx** - No longer needed since Cloudflare handles SSL
2. **Removed Apache** - Phoenix serves the HTML files directly
3. **Updated Phoenix** - Added `PageController` to serve Angular app for SPA routing
4. **Simplified routing** - Phoenix serves everything from one port

### Benefits:
- **Simpler** - 2 services instead of 4 (just DB + Phoenix)
- **Less memory** - No nginx or Apache containers (~128MB saved)
- **Same cost** - Still <$10/month
- **Easier maintenance** - One less reverse proxy to configure

---

## Option 1: Improved Docker Compose (Recommended)

**File: `docker-compose.prod.yml`** (already updated)

### Improvements:
- ✅ **Health checks** - Containers restart automatically if unhealthy
- ✅ **Resource limits** - Prevents containers from consuming all memory (important on small instances)
- ✅ **Better restart policies** - `unless-stopped` instead of `always` (more graceful)
- ✅ **Security** - Database only exposed to localhost
- ✅ **Updated PostgreSQL** - Using postgres:15-alpine (more secure, smaller)
- ✅ **Dependency management** - Services wait for dependencies to be healthy

### Setup:
```bash
# Install docker-compose (if not already installed)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Start services
docker compose -f docker-compose.prod.yml up -d

# View logs
docker compose -f docker-compose.prod.yml logs -f
```

### Auto-start on boot (systemd):
```bash
# Copy the systemd service file
sudo cp docker-compose.service /etc/systemd/system/ersventaja.service

# Edit the file to match your username and path
sudo nano /etc/systemd/system/ersventaja.service
# Update: WorkingDirectory and User fields

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable ersventaja.service
sudo systemctl start ersventaja.service

# Check status
sudo systemctl status ersventaja.service
```

---

## Option 2: Simplified with Cloudflare (Easiest SSL)

**File: `docker-compose-simple.yml`**

### Benefits:
- ✅ **Free SSL** - Cloudflare handles SSL termination (no Let's Encrypt needed)
- ✅ **DDoS protection** - Built-in Cloudflare protection
- ✅ **CDN** - Static files served from Cloudflare edge
- ✅ **Simpler** - No certificate management on server
- ✅ **Same cost** - Cloudflare free tier is sufficient

### Setup:
1. **Point DNS to your EC2 instance** (via Cloudflare)
2. **Enable Cloudflare SSL** (Flexible or Full mode)
3. **Use `docker-compose-simple.yml`** instead of `docker-compose.prod.yml`

```bash
docker compose -f docker-compose-simple.yml up -d
```

---

## Option 3: Use AWS RDS (If budget allows ~$15/month)

If you can spend a bit more, consider **AWS RDS PostgreSQL (db.t3.micro)**:
- Managed backups
- Automatic patches
- Multi-AZ (optional)
- Better security isolation

**Cost:** ~$15/month (still very affordable)

To use RDS:
1. Create RDS PostgreSQL instance in AWS Console
2. Update `.env` with RDS connection string
3. Remove `db` service from docker-compose
4. Add security group rules to allow EC2 → RDS connection

---

## Resource Usage Tips for Small Instances

Your improved docker-compose now has resource limits:
- Database: 128-256MB
- App: 256-512MB  
- Web server: 32-64MB
- Nginx: 32-64MB

**Total:** ~512MB-896MB (fits comfortably in 1GB instance)

### Monitor resources:
```bash
# Check container resource usage
docker stats

# Check disk usage
df -h
docker system df
```

---

## Quick Comparison

| Feature | Current Setup | Improved Setup | Cloudflare Setup |
|---------|--------------|----------------|------------------|
| Cost | <$10/month | <$10/month | <$10/month |
| Health Checks | ❌ | ✅ | ✅ |
| Resource Limits | ❌ | ✅ | ✅ |
| Auto-restart | Manual | ✅ (systemd) | ✅ (systemd) |
| SSL Management | Manual certs | Manual certs | ✅ Automatic |
| DDoS Protection | ❌ | ❌ | ✅ |
| Setup Complexity | Medium | Low | Very Low |

---

## Recommended: Use Option 2 (Cloudflare) + systemd service

This gives you:
- Easiest SSL management (set it and forget it)
- Better security (DDoS protection)
- Same cost
- Simpler maintenance

Steps:
1. Set up Cloudflare DNS for your domain
2. Use `docker-compose-simple.yml`
3. Set up systemd service for auto-start
4. Done! ✅

