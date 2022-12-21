import { BrowserModule } from '@angular/platform-browser';
import { NgModule, LOCALE_ID } from '@angular/core';
import { AppComponent } from './app.component';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { NgbNavModule } from '@ng-bootstrap/ng-bootstrap';
import { AppRoutingModule } from './app-routing.module';
import { ControlpanelComponent } from './pages/controlpanel/controlpanel.component';
import { HomepageComponent } from './pages/homepage/homepage.component';
import { LoginComponent } from './pages/login/login.component';
import { HttpClientModule } from '@angular/common/http';
import { ReactiveFormsModule } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { DatePipe, HashLocationStrategy, LocationStrategy, registerLocaleData } from '@angular/common';
import localePt from '@angular/common/locales/pt';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule} from '@angular/material/datepicker';
import { MatTabsModule} from '@angular/material/tabs';
import { NgxMatFileInputModule } from '@angular-material-components/file-input';
import { DateAdapter, MatNativeDateModule, NativeDateAdapter } from '@angular/material/core';
import { FlexLayoutModule } from '@angular/flex-layout';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatCheckboxModule } from '@angular/material/checkbox';

export class MyDateAdapter extends NativeDateAdapter{
  parse(value: string) {
    let it=value.split('/');
    if (it.length==3)
    return new Date(+it[2],+it[1]-1,+it[0],12)
  }

  format(date: Date, displayFormat: Object) {
    return ('0'+date.getDate()).slice(-2)+'/'+
           ('0'+(date.getMonth()+1)).slice(-2)+'/'+date.getFullYear()
  }
}

registerLocaleData(localePt);

@NgModule({
  declarations: [
    AppComponent,
    ControlpanelComponent,
    HomepageComponent,
    LoginComponent
  ],
  imports: [
    BrowserModule,
    NgbModule,
    FontAwesomeModule,
    NgbNavModule,
    AppRoutingModule,
    HttpClientModule,
    ReactiveFormsModule,
    FormsModule,
    BrowserAnimationsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatTableModule,
    MatSelectModule,
    NgxMatFileInputModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatTabsModule,
    FlexLayoutModule,
    MatProgressSpinnerModule,
    MatCheckboxModule,
  ],
  providers: [ DatePipe, {provide: LOCALE_ID, useValue: 'pt-BR'},
  {provide: DateAdapter, useClass: MyDateAdapter}, {provide: LocationStrategy, useClass: HashLocationStrategy}],
  bootstrap: [AppComponent]
})
export class AppModule { }


