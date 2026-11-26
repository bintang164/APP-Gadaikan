<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProfileUpdateRequest;
use App\Models\UserProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function update(ProfileUpdateRequest $request): JsonResponse
    {
        $user = $request->user();

        $user = DB::transaction(function () use ($request, $user) {
            if ($request->has('name')) {
                $user->name = $request->input('name');
            }
            if ($request->has('phone')) {
                $user->phone = $request->input('phone');
            }
            if ($request->has('email')) {
                $user->email = $request->input('email');
            }
            $user->save();

            $profile = UserProfile::firstOrCreate(['user_id' => $user->id]);
            if ($request->has('address')) {
                $profile->address = $request->input('address');
                $profile->save();
            }

            return $user->load('profile');
        });

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'phone' => $user->phone,
            'email' => $user->email,
            'address' => $user->profile?->address,
        ]);
    }
}
