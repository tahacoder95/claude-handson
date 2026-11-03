/** True for UNIQUE / PRIMARY KEY violations, whichever SQLite driver raised them. */
export function isUniqueViolation(error) {
  const codes = [error?.code, error?.extendedCode, error?.cause?.code].filter(Boolean).map(String);
  return (
    codes.some((code) => code.includes('CONSTRAINT_UNIQUE') || code.includes('CONSTRAINT_PRIMARYKEY'))
    || /UNIQUE constraint failed/i.test(String(error?.message ?? ''))
  );
}
