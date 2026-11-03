/**
 * Saves every file with `saveOne`, or none: if any upload fails, the ones that succeeded are
 * deleted again before the error is rethrown.
 */
export async function saveAll(files, saveOne, deleteRefs) {
  const results = await Promise.allSettled(files.map(saveOne));
  const saved = results.filter((result) => result.status === 'fulfilled').map((result) => result.value);
  const failure = results.find((result) => result.status === 'rejected');
  if (failure) {
    await deleteRefs(saved).catch(() => {});
    throw failure.reason;
  }
  return saved;
}
