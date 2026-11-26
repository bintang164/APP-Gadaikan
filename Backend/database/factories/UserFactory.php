<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => '08'.$this->faker->unique()->numerify('##########'),
            'password' => 'demo1234',
            'role' => 'customer',
            'remember_token' => Str::random(10),
        ];
    }
}
