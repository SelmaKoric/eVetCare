using System;
using eVetCare.Model.Enums;

namespace eVetCare.Services.Helpers
{
    public static class AppointmentStateMachine
    {
        private static readonly Dictionary<AppointmentStatusEnum, List<AppointmentStatusEnum>> allowedTransitions = new()
        {
            { AppointmentStatusEnum.Pending, new() { AppointmentStatusEnum.Approved, AppointmentStatusEnum.Rejected, AppointmentStatusEnum.Canceled } },
            { AppointmentStatusEnum.Approved, new() { AppointmentStatusEnum.Completed, AppointmentStatusEnum.Canceled } },
            { AppointmentStatusEnum.Rejected, new() {} },
            { AppointmentStatusEnum.Completed, new() {} },
            { AppointmentStatusEnum.Canceled, new() {} }
        };

        public static bool CanTransition(int currentStatusId, int newStatusId)
        {
            if (!Enum.IsDefined(typeof(AppointmentStatusEnum), currentStatusId) ||
                !Enum.IsDefined(typeof(AppointmentStatusEnum), newStatusId))
            {
                return false;
            }

            var current = (AppointmentStatusEnum)currentStatusId;
            var next = (AppointmentStatusEnum)newStatusId;

            return allowedTransitions.TryGetValue(current, out var allowedNextStates)
                && allowedNextStates.Contains(next);
        }
    }
}

