import { Component, OnInit } from '@angular/core';
import { SecurityService } from 'src/app/services/security.service';
import { BehaviorSubject, Observable, of, Subject } from 'rxjs';
import { PolicyService } from 'src/app/services/policy.service';
import { Policy } from 'src/app/model/policy.model';
import { FormGroup, FormBuilder } from '@angular/forms';
import { Insurer } from 'src/app/model/insurer.model';
import { InsurerService } from 'src/app/services/insurer.service';
import { NgbDateStruct } from '@ng-bootstrap/ng-bootstrap';
import { faCalendar } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-controlpanel',
  templateUrl: './controlpanel.component.html',
  styleUrls: ['./controlpanel.component.css']
})
export class ControlpanelComponent implements OnInit {
  displayedColumns: string[] = ['renewal', 'days', 'name', 'insurer', 'additional', 'start', 'end', 'download'];
  displayedColumnsCurrent: string[] = ['days', 'name', 'insurer', 'additional', 'start', 'end', 'download'];  
  displayedColumnsAll: string[] = ['name', 'insurer', 'additional', 'start', 'end', 'download', 'delete'];
  signedin: boolean = false;
  policies$: Observable<Policy[]>;
  queryCurrentPolicies$: Observable<Policy[]>;
  queryCurrentForm: FormGroup;
  queryPoliciesSubject$: BehaviorSubject<Policy[]> = new BehaviorSubject<Policy[]>([]);
  queryPolicies$: Observable<Policy[]>;
  queryPolicies: Policy[];
  insurers$: Observable<Insurer[]>;
  queryForm: FormGroup;
  insertForm: FormGroup;
  model: NgbDateStruct;
  file: string | ArrayBuffer;
  fileName: string;
  accept: "application/pdf";
  faCalendar = faCalendar;
  addingPolicy = false;
  displayAlert = false;
  displaySuccess = false;
  danger: 'Alertando aos usuarios';
  displayQueryCurrent = false;
  displayQueryAll = false;
  constructor(private securityService: SecurityService, private formBuilder: FormBuilder,
    private policyService: PolicyService, private insurerService: InsurerService) {
    this.queryCurrentForm = this.formBuilder.group({
      query: ''
    });
    this.queryForm = this.formBuilder.group({
      query: ''
    });
    this.insertForm = this.formBuilder.group({
      name: '',
      insurer: 0,
      additionalInfo: '',
      startDate: null,
      endDate: null,
      file: ''
    });
  }

  async ngOnInit() {
    this.signedin = this.securityService.verifyAuthentication(sessionStorage.getItem("Token"));
    this.loadData();
  }

  loadData() {
    this.policies$ = this.policyService.getDuePolicies();
    this.insurers$ = this.insurerService.getInsurers();
  }

  calculateDays(endDate: Date): number {
    let nowDate = new Date();
    endDate = new Date(endDate);
    return Math.floor((endDate.getTime() - nowDate.getTime()) / 1000 / 60 / 60 / 24);
  }

  fileUrl(fileName: string) {
    return (`https://policiesrsventaja.s3-sa-east-1.amazonaws.com/${fileName}`)
  }

  onCurrentPoliciesSubmit(queryCurrentForm: FormGroup) {
    if (queryCurrentForm.value.query.length > 0) {
      this.displayQueryCurrent = false;
      this.queryCurrentPolicies$ = this.policyService.getPoliciesQuery(queryCurrentForm.value.query, true);
      this.queryCurrentForm.reset();
    } else {
      this.displayQueryCurrent = true;
    }
  }

  onPoliciesSubmit(queryForm: FormGroup) {
    this.queryPolicies$ = this.queryPoliciesSubject$.asObservable();
    if (queryForm.value.query.length > 0) {
      this.displayQueryAll = false;
      this.policyService.getPoliciesQuery(queryForm.value.query, false).subscribe(policies => {
        this.queryPolicies = policies;
        this.queryPoliciesSubject$.next(policies);
        });
      this.queryForm.reset();
    } else {
      this.displayQueryAll = true;
    }
  }

  async updateRenewalStarted(id: number, evt) {
    let bool = !evt;
    await this.policyService.updateRenewalStarted(id, bool).toPromise();;
  }

  async onInsertSubmit(insertForm: FormGroup) {
    this.addingPolicy= true;
    const form = insertForm.value;
    if (form.additionalInfo.length > 0 && form.name.length > 0 && form.insurer > 0 && form.startDate && form.endDate && form.additionalInfo.length > 0) {
      this.displayAlert = false;
      await this.policyService.addPolicy(form.name.toUpperCase(), form.additionalInfo.toUpperCase(), form.startDate, form.endDate, form.insurer, this.file as string, this.fileName).toPromise();
      insertForm.reset();      
      this.displaySuccess = true;
    } else {
      this.displayAlert = true;
    }
    this.addingPolicy = false;
  }

  handleUpload() {
    const file = this.insertForm.value.file;
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
      this.file = (reader.result as string).split(';base64,')[1];
      this.fileName = file.name;
    };
  }

  delete(id: number, fileName: string) {
    this.policyService.deletePolicy(id, fileName).subscribe(_ =>
      {
        var index = this.queryPolicies.map(x => {
          return x.id;
        }).indexOf(id);  

        this.queryPolicies.splice(index, 1);
        this.queryPoliciesSubject$.next(this.queryPolicies.slice(0));
      }
      );  
  }

  close() {
    this.displayAlert = false;
    this.displaySuccess = false;
  }

  closeQueryCurrent() {
    this.displayQueryCurrent = false;
  }

  closeQueryAll() {
    this.displayQueryAll = false;
  }
}
