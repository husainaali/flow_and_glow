# Refactoring Status: Services → Programs & Service Types

## ✅ Completed

### 1. Core Models
- ✅ Created `ServiceTypeModel` for service categories (Yoga, Pilates, Nutrition, Therapy)
- ✅ Renamed `ServiceModel` to `ProgramModel`
- ✅ Updated `CenterModel` to use `serviceTypes` and `programs` lists

### 2. Services Layer
- ✅ Updated `firestore_service.dart`:
  - Renamed all service methods to program methods (`getPrograms`, `createProgram`, etc.)
  - Added service type methods (`getServiceTypes`, `createServiceType`, etc.)

### 3. Providers
- ✅ Updated `firestore_provider.dart`:
  - Renamed `servicesProvider` → `programsProvider`
  - Renamed `servicesByCategoryProvider` → `programsByCategoryProvider`
  - Renamed `servicesByCenterProvider` → `programsByCenterProvider`

### 4. Customer Screens
- ✅ Updated `center_detail_screen.dart`:
  - Changed all `center.services` references to `center.programs`

### 5. Admin Screens (Partial)
- ✅ Updated `center_profile_screen.dart` variables:
  - Changed `_services` to `_serviceTypes` and `_programs`
  - Updated UI to show two sections: Services and Programs

## ⚠️ Remaining Tasks

### Critical - App Won't Compile Without These:

1. **center_profile_screen.dart** - Missing Methods:
   ```dart
   // Need to implement:
   - _buildServiceTypeCard(int index, ServiceTypeModel serviceType)
   - _showAddServiceTypeDialog()
   - _buildProgramCard(int index, ProgramModel program) // rename from _buildServiceCard
   - _showAddProgramDialog() // rename from _showAddServiceDialog
   - _deleteServiceType(int index)
   - _deleteProgram(int index) // rename from _deleteService
   ```

2. **customer_home_screen.dart**:
   - Replace `servicesProvider` with `programsProvider`
   - Replace `servicesByCategoryProvider` with `programsByCategoryProvider`

3. **centers_management_screen.dart** (Super Admin):
   - Replace `center.services` with `center.programs`

4. **add_service_dialog.dart**:
   - Rename file to `add_program_dialog.dart`
   - Update to use `ProgramModel`
   - Add dropdown to select service type

### Optional - For Better UX:

5. **program_detail_screen.dart**:
   - Update parameter name from `service` to `program` (if not already done)
   - Update all internal references

6. **Create Service Type Management Dialog**:
   - Simple dialog to add service types (name, description, icon)

## Quick Fix Guide

### For center_profile_screen.dart:

The easiest approach is to:
1. Rename `_buildServiceCard` → `_buildProgramCard`
2. Rename `_showAddServiceDialog` → `_showAddProgramDialog`
3. Rename `_deleteService` → `_deleteProgram`
4. Create new methods for service types (simpler than programs):
   - `_buildServiceTypeCard` - Just show name and description
   - `_showAddServiceTypeDialog` - Simple form with name and description fields
   - `_deleteServiceType` - Remove from list

### For customer_home_screen.dart:

Find and replace:
- `servicesProvider` → `programsProvider`
- `servicesByCategoryProvider` → `programsByCategoryProvider`

### For centers_management_screen.dart:

Find and replace:
- `.services` → `.programs`

## Testing Checklist

After completing remaining tasks:
- [ ] Center admin can add service types
- [ ] Center admin can add programs linked to service types
- [ ] Customer can view programs on center detail page
- [ ] Customer home screen shows programs correctly
- [ ] Super admin can see center programs

## Notes

- The database structure in Firestore will need to be updated for existing centers
- Consider adding a migration script if there's production data
- Service types could eventually be moved to a global collection for consistency across centers
