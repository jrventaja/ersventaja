import { Component, OnInit } from '@angular/core';
import { SecurityService } from 'src/app/services/security.service';
import { FormBuilder, FormGroup, FormControl, NgForm } from '@angular/forms';
import { Router } from '@angular/router';
import { NgbActiveModal, NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { Observable, of } from 'rxjs';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  signForm: FormGroup;
  sessionStorage = sessionStorage;
  displayWrongAuth = false;
  displayNotFilled = false;
  authenticating = false;
  constructor(private securityService: SecurityService, private formBuilder: FormBuilder, private router: Router, private modal: NgbModal) {
    this.signForm = this.formBuilder.group({
      user: '',
      password: ''
    });
  }
  ngOnInit(): void {
  }

  async login(username: string, password: string) {
    var userTokenData = await this.securityService.getToken(username, password).toPromise();
    sessionStorage.setItem("Token", userTokenData.access_token)
  }

  async onSubmit(signForm: FormGroup) {
    this.authenticating = true;
    if (signForm.value.user.length > 0 && signForm.value.password.length > 0) {
      this.displayNotFilled = false;
      this.displayWrongAuth = false;
      var userTokenData = await this.securityService.getToken(signForm.value.user, signForm.value.password).toPromise().catch(() => {
        return null;
      });
      if (userTokenData != null) {
        sessionStorage.setItem("Token", userTokenData.access_token)
        this.router.navigate(['/controlpanel'])
      } else {
        this.displayWrongAuth = true;
        this.signForm.reset();
      }
    } else {
      this.displayNotFilled = true;
    }
    this.authenticating = false;
  }
  closeFilled(){
    this.displayNotFilled = false;
  }

  closeAuth(){
    this.displayWrongAuth = false;
  }
}
