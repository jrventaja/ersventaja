import { Component, OnInit } from '@angular/core';
import {  faEnvelope, faCar , faHome, faArrowUp, faHeartbeat, faBuilding, faBriefcase, faMobileAlt, faPencilAlt} from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-homepage',
  templateUrl: './homepage.component.html',
  styleUrls: ['./homepage.component.css']
})
export class HomepageComponent {
  faCar = faCar;
  faHome = faHome;
  faHeartbeat = faHeartbeat;
  faBuilding = faBuilding;
  faBriefcase = faBriefcase;
  faMobileAlt = faMobileAlt;
  isNavbarCollapsed = false;
  faArrowUp = faArrowUp;
  faEnvelope = faEnvelope;
  faPencil = faPencilAlt;
}
