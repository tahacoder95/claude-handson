import { HttpError } from '../utils/httpError.js';

/** Validates `data` against a zod schema, throwing a 400 with the first issue's message. */
export function parse(schema, data) {
  const result = schema.safeParse(data);
  if (!result.success) {
    throw new HttpError(400, result.error.issues[0]?.message ?? 'Invalid request.');
  }
  return result.data;
}

/** Route ids that aren't positive integers can't exist, so they're a 404, not a 400. */
export function parseId(schema, value) {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new HttpError(404, 'Not found.');
  }
  return result.data;
}
