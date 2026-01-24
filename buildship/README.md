# BuildShip Workflows

This directory contains the exported JSON configurations for the 3 BuildShip serverless workflows used by Layers.

## Workflows

### 1. Run Layering Job (`01-run-layering-job.json`)
- **Trigger**: Supabase webhook on `projects` table INSERT
- **Purpose**: When a new project is created, triggers AI layer processing

### 2. Cleanup Project (`02-cleanup-project.json`)
- **Trigger**: Supabase webhook on `project_layers` table INSERT/UPDATE/DELETE
- **Purpose**: Maintains data consistency when layers change

### 3. Build Export (`03-build-export.json`)
- **Trigger**: Supabase webhook on `exports` table INSERT
- **Purpose**: Generates final export files when user requests an export

## Configuration

All workflows connect to Supabase project: `dbluxquekhkihatcjplz`

## Import Instructions

To restore these workflows in BuildShip:
1. Go to BuildShip dashboard
2. Create new workflow
3. Use import/paste JSON feature
4. Configure OAuth integrations (Supabase auth)
