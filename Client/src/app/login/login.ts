import { Component } from '@angular/core';
import { FormControl, FormGroup, FormsModule, Validators, ReactiveFormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { RouterModule } from '@angular/router';
import { SnackService } from '../services/snack.service';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-login',
  standalone: false,
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  loginFormGroup = new FormGroup({
  username: new FormControl('', [Validators.required])
  });

  constructor(
    private router: Router, private snackService: SnackService, private userService: UserService) {
  }

  get username(): string {
    return this.loginFormGroup.get('username')?.value ?? '';
  }


  login(): void {
    if (this.loginFormGroup.valid) {
      console.log('Login attempted with', this.username);
      this.userService.login(this.username).subscribe({
        next: (response) => {
          this.snackService.displaySnack('Login successful!');
          this.router.navigate(['/library']);
        },
        error: (error) => {
          this.snackService.displayError('Login failed. Please try again.');
        }
      });
    } else {
      this.snackService.displayError('Please enter a valid username.');
    } 
  }
}