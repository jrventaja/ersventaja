import { Injectable } from '@angular/core';
import { map, catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { HttpParams, HttpClient, HttpHeaders } from '@angular/common/http';
import { UserToken } from '../model/usertoken.model';
import { Policy } from '../model/policy.model';
import { FileResponse } from '../model/fileresponse.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class PolicyService {

  constructor(
    private httpClient: HttpClient,
  ) { }

  private _httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
        'Authorization' : `Bearer ${sessionStorage.getItem("Token")}`
    })
  };

  getDuePolicies() {
    return this.httpClient
      .get<Policy[]>(`${environment.apiEndpoint}/api/policies/last-30-days`, this._httpOptions);
  }

  getPoliciesQuery(query: string, currentOnly: boolean) {
    return this.httpClient
      .get<Policy[]>(`${environment.apiEndpoint}/api/policies?name=${query}&current_only=${currentOnly}`, this._httpOptions);
  }

  updateRenewalStarted(id: number, status: boolean) {
    var request = {
      status: status
    };
    return this.httpClient
      .put<boolean>(`${environment.apiEndpoint}/api/policies/${id}`, JSON.stringify(request), this._httpOptions);
  }

  addPolicy(name: string, additionalInfo: string, startDate: Date, endDate: Date, insurerId: number, file: string, fileName: string) {
    var request = {
      name: name,
      detail: additionalInfo,
      start_date: startDate.toISOString().split('T')[0],
      end_date: endDate.toISOString().split('T')[0],
      insurer_id: insurerId,
      encoded_file: file
    };
    return this.httpClient
      .post(`${environment.apiEndpoint}/api/policies`, JSON.stringify(request), this._httpOptions);
  }

  deletePolicy(id: number, fileName: string){
    return this.httpClient.delete(`${environment.apiEndpoint}/api/policies/${id}`, this._httpOptions);
  }

  private extractData(res: any): any {
    const body = res;
    return body || {};
  }

  private handleError(error: any) {
    if (error.status === 401) {
      throw error;
    } else {
      throw error;
    }
  }
}
