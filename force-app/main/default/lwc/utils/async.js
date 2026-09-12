export function debounce(func, time = 300) {
  let timeoutId;

  return (...args) => {
    clearTimeout(timeoutId);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, time);
  };
}
