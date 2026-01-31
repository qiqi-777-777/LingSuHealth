---
name: "ui-ux-pro-max"
description: "Provides comprehensive UI/UX design guidance and rules. Invoke when designing UI, choosing palettes/typography, reviewing UX issues, or implementing accessibility."
---

# UI/UX Pro Max - Design Intelligence

Comprehensive design guide for web and mobile applications with priority-based UX rules and design system recommendations.

## When to Apply

- Designing new UI components or pages
- Choosing color palettes and typography
- Reviewing code for UX issues
- Building landing pages or dashboards
- Implementing accessibility requirements

## Rule Categories by Priority

1. Accessibility (CRITICAL)
2. Touch & Interaction (CRITICAL)
3. Performance (HIGH)
4. Layout & Responsive (HIGH)
5. Typography & Color (MEDIUM)
6. Animation (MEDIUM)
7. Style Selection (MEDIUM)
8. Charts & Data (LOW)

## Quick Reference

**Accessibility**
- Minimum 4.5:1 contrast for normal text
- Visible focus rings on interactive elements
- Descriptive alt text for meaningful images
- aria-label for icon-only buttons
- Tab order matches visual order
- Use label with for form inputs

**Touch & Interaction**
- Minimum 44x44px touch targets
- Use click/tap for primary interactions
- Disable button during async operations
- Clear error messages near the problem
- Add cursor-pointer to clickable elements

**Performance**
- Use WebP, srcset, and lazy loading for images
- Respect prefers-reduced-motion
- Reserve space for async content to avoid jumps

**Layout & Responsive**
- Use viewport meta width=device-width initial-scale=1
- Minimum 16px body text on mobile
- Avoid horizontal scroll
- Define z-index scale (10, 20, 30, 50)

**Typography & Color**
- Line-height 1.5–1.75 for body text
- Limit line length to 65–75 characters
- Pair heading/body fonts with compatible personalities

**Animation**
- Use 150–300ms for micro-interactions
- Prefer transform/opacity over width/height
- Use skeletons or spinners for loading states

**Style Selection**
- Match style to product type
- Keep visual style consistent across pages
- Prefer SVG icons over emoji icons

**Charts & Data**
- Match chart type to data type
- Use accessible color palettes
- Provide table alternative for accessibility

## How to Use

### Step 1: Analyze User Requirements

Extract:
- Product type
- Style keywords
- Industry
- Tech stack

### Step 2: Generate Design System (Required)

Run the design-system search first:

```
python3 skills/ui-ux-pro-max/scripts/search.py "<product_type> <industry> <keywords>" --design-system -p "Project Name"
```

### Step 2b: Persist Design System (Optional)

```
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name"
```

For page overrides:

```
python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

### Step 3: Apply Rules in Order

Address CRITICAL items first, then HIGH, then MEDIUM, then LOW.
