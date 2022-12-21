import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ControlpanelComponent } from './pages/controlpanel/controlpanel.component';
import { HomepageComponent } from './pages/homepage/homepage.component';
import { LoginComponent } from './pages/login/login.component';

const routes: Routes = [
  { path: 'controlpanel', component: ControlpanelComponent },
  { path: 'homepage', component: HomepageComponent},
  { path: '', redirectTo: '/homepage', pathMatch: 'full' },
  { path: 'login', component: LoginComponent }  
];


@NgModule({
  imports: [RouterModule.forRoot(routes, { useHash: true})],
  exports: [RouterModule]
})
export class AppRoutingModule {}