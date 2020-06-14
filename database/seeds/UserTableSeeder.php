<?php

use Illuminate\Database\Seeder;

class UserTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('users')->insert([
            'name' => 'John Doe',
            'email' => 'angga@example.com',
            'password' => app('hash')->make('angga'),
            'remember_token' => str_random(10),
        ]);
    }
}
