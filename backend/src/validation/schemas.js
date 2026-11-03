import { z } from 'zod';

export const CATEGORIES = ['electronics', 'home', 'fashion', 'vehicles', 'books', 'sports', 'other'];
export const CONDITIONS = ['new', 'like_new', 'good', 'fair'];
export const STATUSES = ['active', 'sold'];
export const SORTS = ['newest', 'price_asc', 'price_desc'];

const username = z
  .string()
  .trim()
  .toLowerCase()
  .regex(/^[a-z0-9_.]{3,30}$/, 'Username must be 3–30 letters, numbers, dots or underscores.');

export const registerSchema = z.object({
  username,
  password: z.string().min(6, 'Password must be at least 6 characters.').max(100),
  display_name: z.string().trim().min(1, 'Enter your name.').max(50, 'Name is too long.'),
  phone: z.string().trim().regex(/^\+?[0-9 ]{7,20}$/, 'Enter a valid phone number.'),
});

export const loginSchema = z.object({
  username: z.string().trim().toLowerCase().min(1, 'Enter your username.'),
  password: z.string().min(1, 'Enter your password.'),
});

const title = z.string().trim().min(3, 'Title needs at least 3 characters.').max(80, 'Title is too long.');
const description = z.string().trim().max(1000, 'Description is too long.');
const price = z.coerce
  .number({ message: 'Enter a price.' })
  .int('Price must be a whole number of AED.')
  .positive('Enter a price above 0.')
  .max(10_000_000, 'Price is too high.');
const category = z.enum(CATEGORIES, { message: 'Choose a category.' });
const condition = z.enum(CONDITIONS, { message: 'Choose a condition.' });
const location = z.string().trim().min(2, 'Add a pickup location.').max(80, 'Location is too long.');

export const createListingSchema = z.object({
  title,
  description: description.default(''),
  price_aed: price,
  category,
  condition,
  location,
});

/** Multipart sends "1,2"; JSON may send [1, 2]. */
const idList = z.preprocess(
  (value) => {
    if (value === undefined || value === '') return [];
    if (Array.isArray(value)) return value;
    return String(value).split(',').map((part) => part.trim()).filter(Boolean);
  },
  z.array(z.coerce.number().int().positive()),
);

export const updateListingSchema = z.object({
  title: title.optional(),
  description: description.optional(),
  price_aed: price.optional(),
  category: category.optional(),
  condition: condition.optional(),
  location: location.optional(),
  status: z.enum(STATUSES, { message: 'Status must be active or sold.' }).optional(),
  remove_photo_ids: idList.optional(),
});

export const searchSchema = z.object({
  q: z.string().trim().max(100).optional(),
  category: category.optional(),
  sort: z.enum(SORTS).default('newest'),
});

export const idParamSchema = z.coerce.number().int().positive();
