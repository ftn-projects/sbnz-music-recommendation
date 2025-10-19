import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';

@Injectable({
  providedIn: 'root'
})
export class SnackService {

  constructor(private snackbar: MatSnackBar) { }

  displaySnack(text: string, duration: number = 1000, action?: string) {
    this.snackbar.open(text, action, { duration: duration });
  }

  displaySnackWithButton(message: string, action: string) {
    this.snackbar.open(message, action);
  }

  displayFirstError(err: HttpErrorResponse) {
    console.log(err);
    if (!err.error) return;
    let message = Object.entries(err.error)[0][1];
    this.displayError(message);
  }

  displayError(message: any) {
    this.displaySnack(`Error: ${message}`, 5000, "OK");
  }
}