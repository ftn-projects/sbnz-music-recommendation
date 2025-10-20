import { Component } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { SnackService } from '../services/snack.service';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-registration',
  standalone: false,
  templateUrl: './registration.html',
  styleUrl: './registration.scss'
})
export class Registration {
  registrationFormGroup = new FormGroup({
    name: new FormControl('', [Validators.required]),
    surname: new FormControl('', [Validators.required]),
    username: new FormControl('', [Validators.required]),
    age: new FormControl('', [Validators.required, Validators.min(1), Validators.max(120)])
  });

  constructor(private router: Router, private snackService: SnackService, private userService: UserService) {}

  get name(): string {
    return this.registrationFormGroup.get('name')?.value ?? '';
  }

  get surname(): string {
    return this.registrationFormGroup.get('surname')?.value ?? '';
  }

  get username(): string {
    return this.registrationFormGroup.get('username')?.value ?? '';
  }

  get age(): string {
    return this.registrationFormGroup.get('age')?.value ?? '';
  }

  register(): void {
    if (this.registrationFormGroup.valid) {
      console.log('Registration attempted with:', {
        name: this.name,
        surname: this.surname,
        username: this.username,
        age: this.age
      });
      this.userService.registerUser(this.name, this.surname, this.username, Number(this.age)).subscribe({
        next: (response) => {
          this.snackService.displaySnack('Registration successful!');
          this.router.navigate(['/login']);
        },
        error: (error) => {
          this.snackService.displayError('Registration failed. Please try again.');
        }
      });
    } else {
      this.snackService.displayError('Please fill in all required fields correctly.');
      return;
    }

  }
}
