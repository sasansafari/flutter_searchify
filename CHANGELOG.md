## [0.1.4] - 2025-07-25

### Added
- `highlightMatch(String text, String query)` function for showing matched query with highlight
- Documentation comments for public methods and state logic

### Changed
- Default `itemBuilder` now uses `highlightMatch` if no builder is provided

### Fixed
- Minor UI inconsistency in padding/margin alignment between input and list items
