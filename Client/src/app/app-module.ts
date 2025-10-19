import { NgModule, provideBrowserGlobalErrorListeners } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';

import { AppRoutingModule } from './app-routing-module';
import { App } from './app';
import { MaterialModule } from './material/material-module';
import { LoginComponent } from './login/login';
import { ReactiveFormsModule } from '@angular/forms';
import { Registration } from './registration/registration';
import { Library } from './library/library';
import { Recommendation } from './recommendation/recommendation';
import { Navbar } from './navbar/navbar';

@NgModule({
  declarations: [
    App,
    LoginComponent,
    Registration,
    Library,
    Recommendation,
    Navbar
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    MaterialModule,
    ReactiveFormsModule
  ],
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideHttpClient(withInterceptorsFromDi())
  ],
  bootstrap: [App]
})
export class AppModule { }
