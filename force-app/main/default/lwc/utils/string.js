export function stringFormat(template, ...args) {
    return template.replace(/\{(\d+)\}/g, (match, index) => {
        const arg = args[index];
        return arg === undefined ? match : arg
    });
  }