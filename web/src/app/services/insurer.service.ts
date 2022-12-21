import { Injectable } from '@angular/core';
import { map, catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { HttpParams, HttpClient, HttpHeaders } from '@angular/common/http';
import { UserToken } from '../model/usertoken.model';
import { Policy } from '../model/policy.model';
import { FileResponse } from '../model/fileresponse.model';
import { Insurer } from '../model/insurer.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class InsurerService {

  constructor(
    private httpClient: HttpClient,
  ) { }

  private _httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
        'Authorization' : `Bearer ${sessionStorage.getItem("Token")}`
    })
  };

  getInsurers() {
    return this.httpClient
      .get<Insurer[]>(`${environment.apiEndpoint}/api/insurers`, this._httpOptions);
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
