// src/users/users.service.ts
import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';
import { CreateUserDto } from './dtos/create-user.dto';
import { UpdateUserDto } from './dtos/update-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  // Lấy tất cả người dùng
  async findAll(): Promise<User[]> {
    this.logger.log('Fetching all users');
    const users = await this.userRepository.find({
      relations: ['role'],
    });
    this.logger.log(`Found ${users.length} users`);
    return users;
  }

  // Lấy người dùng theo email
  async findByEmail(email: string): Promise<User | null> {
    this.logger.log(`Finding user by email: ${email}`);
    const user = await this.userRepository.findOneBy({ email });
    if (user) {
      this.logger.log(`Found user with email: ${email}`);
    } else {
      this.logger.warn(`No user found with email: ${email}`);
    }
    return user;
  }

  // Lấy thông tin người dùng theo ID
  async findOne(id: number): Promise<User> {
    this.logger.log(`Finding user by ID: ${id}`);
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['role'],
    });
    if (!user) {
      this.logger.warn(`User not found with ID: ${id}`);
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    this.logger.log(`Found user with ID: ${id}`);
    return user;
  }

  // Tạo mới người dùng
  async create(createUserDto: CreateUserDto): Promise<User> {
    this.logger.log(`Creating new user with email: ${createUserDto.email}`);
    const { password, role_id = 11, ...userData } = createUserDto;

    const user = this.userRepository.create({
      ...userData,
      password_hash: await bcrypt.hash(password, 10),
      role: { id: role_id },
    });

    const savedUser = await this.userRepository.save(user);
    this.logger.log(`Created new user with ID: ${savedUser.id}`);
    return savedUser;
  }

  // Cập nhật người dùng
  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    this.logger.log(`Updating user with ID: ${id}`);
    const user = await this.findOne(id);
    const { password, role_id, ...updateData } = updateUserDto;

    if (password) {
      this.logger.log(`Updating password for user ID: ${id}`);
      updateData['password_hash'] = await bcrypt.hash(password, 10);
    }

    if (role_id) {
      this.logger.log(`Updating role for user ID: ${id} to role: ${role_id}`);
      updateData['role'] = { id: role_id };
    }

    Object.assign(user, updateData);
    const updatedUser = await this.userRepository.save(user);
    this.logger.log(`Successfully updated user with ID: ${id}`);
    return updatedUser;
  }

  // Xóa người dùng
  async remove(id: number): Promise<void> {
    this.logger.log(`Attempting to remove user with ID: ${id}`);
    const user = await this.findOne(id);
    await this.userRepository.remove(user);
    this.logger.log(`Successfully removed user with ID: ${id}`);
  }
}
