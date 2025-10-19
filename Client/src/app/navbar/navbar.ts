import { Component, inject, computed } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { UserService } from '../services/user.service';
import { filter, map } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-navbar',
  standalone: false,
  templateUrl: './navbar.html',
  styleUrl: './navbar.scss'
})
export class Navbar {
  private readonly router = inject(Router);
  private readonly userService = inject(UserService);

  // Track current route
  readonly currentRoute = toSignal(
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd),
      map(() => this.router.url)
    ),
    { initialValue: this.router.url }
  );

  // Computed values for navbar visibility
  readonly isLoginPage = computed(() => this.currentRoute() === '/login');
  readonly isRegistrationPage = computed(() => this.currentRoute() === '/registration');
  readonly isAuthPage = computed(() => this.isLoginPage() || this.isRegistrationPage());
  readonly isLoggedIn = this.userService.isLoggedIn;

  logout(): void {
    this.userService.logout();
    this.router.navigate(['/login']);
  }
}
