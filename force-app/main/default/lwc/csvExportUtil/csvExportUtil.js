/**
 * Universal CSV Export Utility for Salesforce Permissions Suite
 * RFC 4180 compliant with UTF-8 BOM encoding for seamless Excel compatibility.
 * Works reliably within Salesforce Lightning Locker Service and LWS.
 */
export function exportToCsv(columns, rows, fileName = 'export.csv') {
  if (!rows || !rows.length || !columns || !columns.length) {
    return;
  }

  // UTF-8 BOM (\uFEFF) ensures Microsoft Excel and other spreadsheet viewers
  // properly parse Unicode characters and column delimiters.
  const BOM = '\uFEFF';

  // Generate header row with quotes
  const headerRow = columns.map((col) => escapeCsvValue(col.label)).join(',');

  // Generate data rows
  const dataRows = rows.map((row) => {
    return columns
      .map((col) => {
        const val = resolveFieldValue(row, col.fieldName);
        return escapeCsvValue(val);
      })
      .join(',');
  });

  const csvContent = BOM + headerRow + '\r\n' + dataRows.join('\r\n');
  const safeFileName = sanitizeFileName(fileName);

  // Trigger download using Data URI (compatible with Salesforce Lightning Locker & modern browsers)
  try {
    const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
    const link = document.createElement('a');
    link.href = encodedUri;
    link.download = safeFileName;
    link.target = '_self';
    document.body.appendChild(link);
    link.click();
    setTimeout(() => {
      if (document.body.contains(link)) {
        document.body.removeChild(link);
      }
    }, 150);
  } catch (err) {
    // Fallback: Blob URL with delayed revocation
    try {
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      if (window.navigator && window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveOrOpenBlob(blob, safeFileName);
      } else {
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = safeFileName;
        link.target = '_self';
        document.body.appendChild(link);
        link.click();
        setTimeout(() => {
          if (document.body.contains(link)) {
            document.body.removeChild(link);
          }
          URL.revokeObjectURL(url);
        }, 500);
      }
    } catch (blobErr) {
      console.error('CSV Export Error: ', blobErr);
    }
  }
}

function resolveFieldValue(obj, fieldPath) {
  if (!obj || !fieldPath) return '';
  const parts = fieldPath.split('.');
  let current = obj;
  for (const part of parts) {
    if (current == null) return '';
    current = current[part];
  }
  if (typeof current === 'boolean') {
    return current ? 'Active' : 'Inactive';
  }
  return current == null ? '' : current;
}

function escapeCsvValue(val) {
  if (val === null || val === undefined) return '""';
  let str = String(val);
  // Double-quote all internal quotes per RFC 4180
  str = str.replace(/"/g, '""');
  // Always wrap in quotes to preserve formatting, commas, newlines, and leading zeroes
  return `"${str}"`;
}

function sanitizeFileName(fileName) {
  if (!fileName) return 'export.csv';
  let name = fileName.replace(/\.csv$/i, '');
  name = name.replace(/[^a-zA-Z0-9_-]/g, '_');
  return `${name}.csv`;
}