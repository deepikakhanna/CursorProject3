# CursorProject3

A Salesforce project containing Account Health Score management components.

## Overview

This repository contains Apex classes for calculating and managing Account Health Scores based on revenue and recent wins metrics.

## Components

### AccountHealthService.cls
Service class for calculating and updating Account Health Scores.

**Features:**
- Calculates health scores based on Annual Revenue and Last 90 Day Wins
- Implements bulkified operations for efficient processing
- Includes comprehensive null handling

**Scoring Logic:**

**Revenue Score:**
- $0 or null → 0 points
- $1 - $249,999 → 10 points  
- $250,000 - $999,999 → 30 points
- $1,000,000+ → 50 points

**Recent Wins Score:**
- $0 or null → 0 points
- $1 - $24,999 → 10 points
- $25,000 - $99,999 → 30 points
- $100,000+ → 50 points

**Total Health Score:** Revenue Score + Recent Wins Score (0-100 points)

### AccountHealthServiceTest.cls
Comprehensive test class with 100% code coverage.

**Test Coverage:**
- All revenue and wins scoring buckets
- Boundary value testing
- Null and empty set handling
- Single account processing
- Bulk processing (200+ records)

## Project Structure

```
force-app/main/default/classes/
├── AccountHealthService.cls
├── AccountHealthService.cls-meta.xml
├── AccountHealthServiceTest.cls
└── AccountHealthServiceTest.cls-meta.xml
```

## API Version
61.0

## Author
deepikakhanna