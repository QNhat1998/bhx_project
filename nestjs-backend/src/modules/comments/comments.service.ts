import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Brackets } from 'typeorm';
import { Comment } from '../../entities/comment.entity';
import { CreateCommentDto } from './dtos/create-comment.dto';
import { UpdateCommentDto } from './dtos/update-comment.dto';
import { CommentFilterDto } from './dtos/comment-filter.dto';

@Injectable()
export class CommentsService {
  private readonly logger = new Logger(CommentsService.name);

  constructor(
    @InjectRepository(Comment)
    private readonly commentRepository: Repository<Comment>,
  ) {}

  async findAll(): Promise<Comment[]> {
    this.logger.log('Fetching all comments');
    const comments = await this.commentRepository.find({
      relations: ['product'],
      order: { created_at: 'DESC' },
    });
    this.logger.log(`Found ${comments.length} comments`);
    return comments;
  }

  async findWithFilters(filterDto: CommentFilterDto) {
    const {
      product_id,
      search,
      status,
      rating,
      page = 1,
      limit = 10,
      sortBy = 'created_at',
      sortOrder = 'DESC',
    } = filterDto;

    const queryBuilder = this.commentRepository.createQueryBuilder('comment');
    queryBuilder.leftJoinAndSelect('comment.product', 'product');

    if (product_id) {
      queryBuilder.andWhere('comment.product_id = :product_id', { product_id });
    }

    if (search) {
      queryBuilder.andWhere(
        new Brackets((qb) => {
          qb.where('comment.content LIKE :search', {
            search: `%${search}%`,
          }).orWhere('comment.customer_name LIKE :search', {
            search: `%${search}%`,
          });
        }),
      );
    }

    if (status !== undefined) {
      queryBuilder.andWhere('comment.status = :status', { status });
    }

    if (rating !== undefined) {
      queryBuilder.andWhere('comment.rating = :rating', { rating });
    }

    // Validate and apply sorting
    if (sortBy && this.isSortColumnValid(sortBy)) {
      queryBuilder.orderBy(`comment.${sortBy}`, sortOrder);
    } else {
      queryBuilder.orderBy('comment.created_at', 'DESC');
    }

    // Apply pagination
    const skip = (page - 1) * limit;
    queryBuilder.skip(skip).take(limit);

    const [comments, total] = await queryBuilder.getManyAndCount();

    return {
      items: comments,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  private isSortColumnValid(column: string): boolean {
    const validColumns = [
      'id',
      'created_at',
      'rating',
      'status',
      'customer_name',
    ];
    return validColumns.includes(column);
  }

  async findOne(id: number): Promise<Comment> {
    this.logger.log(`Finding comment with ID: ${id}`);
    const comment = await this.commentRepository.findOne({
      where: { id },
      relations: ['product'],
    });

    if (!comment) {
      this.logger.warn(`Comment with ID ${id} not found`);
      throw new NotFoundException(`Comment with ID ${id} not found`);
    }

    return comment;
  }

  async create(createCommentDto: CreateCommentDto): Promise<Comment> {
    this.logger.log(
      `Creating new comment for product ID: ${createCommentDto.product_id}`,
    );
    const comment = this.commentRepository.create(createCommentDto);
    const savedComment = await this.commentRepository.save(comment);
    this.logger.log(`Created comment with ID: ${savedComment.id}`);
    return this.findOne(savedComment.id);
  }

  async update(
    id: number,
    updateCommentDto: UpdateCommentDto,
  ): Promise<Comment> {
    this.logger.log(`Updating comment with ID: ${id}`);
    const comment = await this.findOne(id);
    Object.assign(comment, updateCommentDto);
    const updatedComment = await this.commentRepository.save(comment);
    this.logger.log(`Updated comment with ID: ${id}`);
    return this.findOne(updatedComment.id);
  }

  async remove(id: number): Promise<void> {
    this.logger.log(`Removing comment with ID: ${id}`);
    const comment = await this.findOne(id);
    await this.commentRepository.remove(comment);
    this.logger.log(`Removed comment with ID: ${id}`);
  }
}
