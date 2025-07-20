using System;

namespace eVetCare.Services.Exceptions
{
    public class AppointmentOverlapException : Exception
    {
        public AppointmentOverlapException()
            : base("There is already an appointment scheduled that overlaps with the requested time.")
        {
        }

        public AppointmentOverlapException(string message)
            : base(message)
        {
        }

        public AppointmentOverlapException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }
}