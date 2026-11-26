<?php

use App\Http\Controllers\Api\Admin\AdminApplicationController;
use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\ApplicationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\DocumentController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function (): void {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [ProfileController::class, 'update']);

    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/simulation/config', [ContentController::class, 'simulationConfig']);
    Route::get('/outlets', [ContentController::class, 'outlets']);
    Route::get('/promotions', [ContentController::class, 'promotions']);
    Route::get('/faqs', [ContentController::class, 'faqs']);

    Route::post('/pawn-applications/documents', [DocumentController::class, 'store']);
    Route::apiResource('pawn-applications', ApplicationController::class)
        ->only(['index', 'store', 'show']);
    Route::get('/pawn-applications/{application}/status-history', [ApplicationController::class, 'statusHistory']);
    Route::post('/pawn-applications/{application}/accept-offer', [ApplicationController::class, 'acceptOffer']);
    Route::post('/pawn-applications/{application}/decline-offer', [ApplicationController::class, 'declineOffer']);

    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::get('/transactions/{transaction}', [TransactionController::class, 'show']);
    Route::post('/transactions/{transaction}/demo-payment', [TransactionController::class, 'demoPayment']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
});

Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function (): void {
    Route::get('/dashboard', [AdminController::class, 'dashboard']);

    Route::get('/applications', [AdminApplicationController::class, 'index']);
    Route::get('/applications/{application}', [AdminApplicationController::class, 'show']);
    Route::get('/applications/{application}/status-history', [AdminApplicationController::class, 'statusHistory']);
    Route::get('/applications/{application}/documents/{document}', [AdminApplicationController::class, 'document']);

    Route::post('/applications/{application}/assessment', [AdminApplicationController::class, 'assessment']);
    Route::post('/applications/{application}/request-revision', [AdminApplicationController::class, 'requestRevision']);
    Route::post('/applications/{application}/review', [AdminApplicationController::class, 'review']);
    Route::post('/applications/{application}/decision', [AdminApplicationController::class, 'decision']);
});
