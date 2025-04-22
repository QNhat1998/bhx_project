import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';
import { RefreshToken } from '../../entities/refresh-token.entity';
import { RegisterDto } from './dtos/register.dto';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(RefreshToken)
    private readonly refreshTokenRepository: Repository<RefreshToken>,
  ) {}

  async register(registerDto: RegisterDto): Promise<User> {
    this.logger.log(`Starting registration for email: ${registerDto.email}`);

    // Check if email already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });
    if (existingUser) {
      this.logger.warn(
        `Registration failed: Email ${registerDto.email} already exists`,
      );
      throw new ConflictException('Email already exists');
    }

    // Check if phone already exists
    const existingPhone = await this.userRepository.findOne({
      where: { phone: registerDto.phone },
    });
    if (existingPhone) {
      this.logger.warn(
        `Registration failed: Phone ${registerDto.phone} already exists`,
      );
      throw new ConflictException('Phone number already exists');
    }

    // Create new user with default role
    this.logger.log('Creating new user with customer role');
    const user = this.userRepository.create({
      ...registerDto,
      password_hash: await bcrypt.hash(registerDto.password, 10),
      role: { id: 11 }, // Default USER role
    });

    const savedUser = await this.userRepository.save(user);
    this.logger.log(`User registered successfully with ID: ${savedUser.id}`);
    return savedUser;
  }

  async login(email: string, password: string) {
    this.logger.log(`Attempting login for email: ${email}`);

    const user = await this.findUserByEmail(email);
    if (!user) {
      this.logger.warn(`Login failed: User not found for email ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await this.checkPassword(
      password,
      user.password_hash,
    );
    if (!isPasswordValid) {
      this.logger.warn(`Login failed: Invalid password for email ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    this.logger.log(`User ${email} logged in successfully`);

    // Generate tokens
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    // Save refresh token to database
    this.logger.log(`Saving refresh token for user ${user.id}`);
    const refreshTokenEntity = new RefreshToken();
    refreshTokenEntity.token = refreshToken;
    refreshTokenEntity.user = user;
    refreshTokenEntity.expires_at = new Date(
      Date.now() + 7 * 24 * 60 * 60 * 1000,
    ); // 7 days
    await this.refreshTokenRepository.save(refreshTokenEntity);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  async refreshAccessToken(refreshToken: string) {
    try {
      // Find the refresh token in the database
      const refreshTokenEntity = await this.refreshTokenRepository.findOne({
        where: { token: refreshToken },
        relations: ['user'],
      });

      if (!refreshTokenEntity) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Check if the refresh token has expired
      if (refreshTokenEntity.expires_at < new Date()) {
        await this.refreshTokenRepository.remove(refreshTokenEntity);
        throw new UnauthorizedException('Refresh token expired');
      }

      // Generate new tokens
      const user = refreshTokenEntity.user;
      const newAccessToken = this.generateAccessToken(user);
      const newRefreshToken = this.generateRefreshToken(user);

      // Update refresh token in database
      await this.refreshTokenRepository.remove(refreshTokenEntity);
      const newRefreshTokenEntity = new RefreshToken();
      newRefreshTokenEntity.token = newRefreshToken;
      newRefreshTokenEntity.user = user;
      newRefreshTokenEntity.expires_at = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000,
      ); // 7 days
      await this.refreshTokenRepository.save(newRefreshTokenEntity);

      return {
        access_token: newAccessToken,
        refresh_token: newRefreshToken,
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async logout(refreshToken: string): Promise<void> {
    const token = await this.refreshTokenRepository.findOne({
      where: { token: refreshToken },
    });
    if (token) {
      await this.refreshTokenRepository.remove(token);
    }
  }

  private async findUserByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  private async checkPassword(
    password: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  private generateAccessToken(user: User): string {
    const secret = process.env.JWT_ACCESS_SECRET;
    if (!secret) {
      throw new Error('JWT_ACCESS_SECRET is not defined');
    }
    return jwt.sign({ userId: user.id, email: user.email }, secret, {
      expiresIn: '15m',
    });
  }

  private generateRefreshToken(user: User): string {
    const secret = process.env.JWT_REFRESH_SECRET;
    if (!secret) {
      throw new Error('JWT_REFRESH_SECRET is not defined');
    }
    return jwt.sign({ userId: user.id }, secret, { expiresIn: '7d' });
  }
}
