import { Injectable } from '@angular/core';
import { map, catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { HttpParams, HttpClient, HttpHeaders } from '@angular/common/http';
import { UserToken } from '../model/usertoken.model';
import { environment } from '../../environments/environment';
@Injectable({
  providedIn: 'root',
})
export class SecurityService {

  constructor(
    private httpClient: HttpClient,
  ) { }

  private _httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json'
    })
  };

  getToken(username: string, password: string) {
    var paramsObject = {
      user: {
        username: username,
        password: password
      }
    }
    return this.httpClient
      .post<UserToken>(`${environment.apiEndpoint}/api/login`, JSON.stringify(paramsObject), this._httpOptions);
  }

  verifyAuthentication(token: string) {
    var parsed_jwt = this.parseJwt(token);
    return parsed_jwt.exp > Date.now() / 1000
  }

  parseJwt (token) {
    var base64Url = token.split('.')[1];
    var base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    var jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));

    return JSON.parse(jsonPayload);
}
}
