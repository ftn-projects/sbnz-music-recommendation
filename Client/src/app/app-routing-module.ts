import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './login/login';
import { Registration } from './registration/registration';
import { Library } from './library/library';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'registration', component: Registration },
  { path: 'library', component: Library }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
