---
name: aws-naming
description: "Normalize filenames for AWS S3 and CloudFront: lowercase, safe characters, extension normalization (.jpeg → .jpg), and .tsv audit log. Usage: /aws-naming <directory_or_file>"
---

# Normalización de assets para AWS S3 + CloudFront

## When to use

Before uploading files to an S3 bucket, or when normalizing existing object keys for CloudFront compatibility.

## Instructions

1. **Read the full CoT**: Load and follow `~/rules/cot/aws_naming.md` from line 1 to end
2. **Identify target files**: List all files in the given directory or validate the single file provided
3. **For each file, apply normalization in order**:
   a. Convert entire filename and extension to lowercase
   b. Replace all whitespace with hyphens (`-`)
   c. Strip accents (ñ → n) and remove all characters except `a-z`, `0-9`, `-`, `_`, `.`
   d. Normalize extensions:
      - `.jpeg` → `.jpg`
      - `.png`, `.svg`, `.ico` → sin cambio
   e. Verify no consecutive dots (`..`) or relative path sequences (`../`, `./`)
   f. Validate total path length ≤ 255 characters (CloudFront limit)
4. **Rename files**: Apply `mv` for each file that changed
5. **Generate audit log**:
   ```bash
   TSV="normalizacion_$(TZ=America/Mexico_City date +'%Y%m%d').tsv"
   printf 'original\tnormalizado\n' > "$TSV"
   ```
   Append one line per file processed (including unchanged files).
6. **Report**: Show summary of renamed files and path to the `.tsv`

## Examples

- `Logo Café.PNG` → `logo-cafe.png`
- `Ícono_Ñoño (2).JPEG` → `icono-nono-2.jpg`
- `banner final.jpeg` → `banner-final.jpg`
- `favicon.ICO` → `favicon.ico`
- `diagrama~v2..svg` → `diagrama-v2.svg`

## Critical rules

- Process ALL files, log ALL in `.tsv` (even those without changes)
- Extension normalization is mandatory: `.jpeg` always becomes `.jpg`
- Only safe characters survive: `a-z`, `0-9`, `-`, `_` and `.` (for extension only)
- Tilde (`~`) is forbidden (CloudFront cache invalidation incompatibility)
- CloudFront path limit: 255 characters; truncate name (preserve extension) if exceeded
- `.tsv` filename uses CST date: `TZ=America/Mexico_City date +'%Y%m%d'`
- Never overwrite an existing file during rename; if collision, append numeric suffix (`-1`, `-2`)

## References

- Detailed CoT: `~/rules/cot/aws_naming.md`
- AWS S3 Object Key naming guidelines: [docs.aws.amazon.com](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-keys.html)
- CloudFront cache behavior path patterns: [docs.aws.amazon.com](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html)
