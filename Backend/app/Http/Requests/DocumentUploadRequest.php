<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DocumentUploadRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'file' => [
                'required',
                'file',
                'mimes:jpg,jpeg,png,pdf',
                'max:5120',
            ],
            'label' => ['sometimes', 'string', 'max:120'],
            'is_sensitive' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'file.mimes' => 'Format berkas harus JPG, PNG, atau PDF.',
            'file.max' => 'Ukuran berkas maksimal 5 MB.',
        ];
    }
}
