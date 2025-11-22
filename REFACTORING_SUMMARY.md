# Service to Program Refactoring Summary

## Overview
Restructured the data model to separate **Service Types** (categories like Yoga, Pilates, Nutrition, Therapy) from **Programs** (scheduled offerings with trainers, dates, and pricing).

## Changes Made

### 1. New Models Created

#### ServiceTypeModel (`lib/models/service_type_model.dart`)
- Represents service categories (Yoga, Pilates, Nutrition, Therapy, etc.)
- Fields: `id`, `name`, `description`, `iconName`, `createdAt`
- Centers can select which service types they offer

#### ProgramModel (`lib/models/program_model.dart`)  
- Renamed from `ServiceModel`
- Represents scheduled programs with specific details
- Added `serviceTypeId` field to link to a ServiceTypeModel
- Fields include: trainer, dates (programStartDate, programEndDate), pricing, schedule

### 2. Updated Models

#### CenterModel (`lib/models/center_model.dart`)
- Changed from `List<ServiceModel> services` to:
  - `List<ServiceTypeModel> serviceTypes` - Types of services offered
  - `List<ProgramModel> programs` - Scheduled programs

### 3. Updated Screens

#### Center Profile Screen (`lib/screens/center_admin/center_profile_screen.dart`)
- Updated imports to use `ProgramModel` and `ServiceTypeModel`
- Changed variables:
  - `_services` → `_serviceTypes` and `_programs`
- UI now has two sections:
  - **Manage Services**: Add service types (Yoga, Pilates, etc.)
  - **Manage Programs**: Add scheduled programs with trainer and dates

## Files That Need Updates

The following files still reference the old `ServiceModel` and need to be updated to use `ProgramModel`:

### Critical Files:
1. **`lib/screens/center_admin/center_profile_screen.dart`**
   - Need to implement:
     - `_buildServiceTypeCard()` method
     - `_showAddServiceTypeDialog()` method
     - `_buildProgramCard()` method (rename from `_buildServiceCard`)
     - `_showAddProgramDialog()` method (rename from `_showAddServiceDialog`)
     - Update delete methods: `_deleteServiceType()`, `_deleteProgram()`

2. **`lib/screens/customer/center_detail_screen.dart`**
   - Replace `center.services` with `center.programs`
   - Update imports from `service_model.dart` to `program_model.dart`

3. **`lib/screens/customer/program_detail_screen.dart`**
   - Update parameter type from `ServiceModel` to `ProgramModel`

4. **`lib/screens/center_admin/add_service_dialog.dart`**
   - Rename to `add_program_dialog.dart`
   - Update to use `ProgramModel`
   - Add dropdown to select `serviceTypeId` from available service types

5. **`lib/providers/firestore_provider.dart`**
   - Update `servicesProvider` to `programsProvider`
   - Change references from `center.services` to `center.programs`

6. **`lib/services/firestore_service.dart`**
   - Rename methods:
     - `getServices()` → `getPrograms()`
     - `getService()` → `getProgram()`
     - `createService()` → `createProgram()`
     - `updateService()` → `updateProgram()`
     - `deleteService()` → `deleteProgram()`
   - Add new methods for ServiceTypes:
     - `getServiceTypes()`
     - `createServiceType()`
     - `updateServiceType()`
     - `deleteServiceType()`

7. **`lib/screens/super_admin/centers_management_screen.dart`**
   - Update references from `services` to `programs`

## Database Structure

### Firestore Collections:
- `centers` collection now has:
  ```
  {
    ...existing fields...
    serviceTypes: [
      { name: "Yoga", description: "...", iconName: "..." },
      { name: "Pilates", description: "...", iconName: "..." }
    ],
    programs: [
      {
        serviceTypeId: "0", // Index or ID of service type
        title: "Morning Yoga Session",
        trainer: "John Doe",
        programStartDate: Timestamp,
        programEndDate: Timestamp,
        ...other fields...
      }
    ]
  }
  ```

## Next Steps

1. **Implement missing methods in center_profile_screen.dart**
2. **Update all customer-facing screens** to use `programs` instead of `services`
3. **Update firestore_service.dart** with new methods
4. **Test the entire flow**:
   - Center admin adds service types
   - Center admin creates programs linked to service types
   - Customers view programs by service type
5. **Migration**: Consider adding a migration script if there's existing data

## Benefits

- **Clear separation**: Service types (what you offer) vs Programs (when/how you offer it)
- **Better organization**: Customers can filter by service type (Yoga, Pilates, etc.)
- **Flexibility**: Centers can offer multiple programs for the same service type
- **Scalability**: Easy to add new service types without changing program structure
