<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\TaskController;

Route::get('/coba', function () {
    return response()->json(['message' => 'API aktif']);
});

// Ini eksplisit agar Laravel pasti mengenali
Route::get('/tasks', [TaskController::class, 'index']);
Route::post('/tasks', [TaskController::class, 'store']);
Route::get('/tasks/{id}', [TaskController::class, 'show']);
Route::put('/tasks/{id}', [TaskController::class, 'update']);
Route::delete('/tasks/{id}', [TaskController::class, 'destroy']);
