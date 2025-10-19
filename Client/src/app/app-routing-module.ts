import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './login/login';
import { Registration } from './registration/registration';
import { Library } from './library/library';
import { Recommendation } from './recommendation/recommendation';

const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'registration', component: Registration },
  { path: 'library', component: Library },
  { path: 'recommendation', component: Recommendation }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
