<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProfileUpdateRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $userId = $this->user()?->id;

        return [
            'name' => ['sometimes', 'required', 'string', 'min:3', 'max:120'],
            'phone' => ['sometimes', 'required', 'string', "unique:users,phone,{$userId}"],
            'email' => ['sometimes', 'required', 'email', "unique:users,email,{$userId}"],
            'address' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }
}
