using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eVetCare.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK__Appointme__Veter__4BAC3F29",
                table: "Appointments");

            migrationBuilder.DropForeignKey(
                name: "FK__Vaccinati__PetID__73BA3083",
                table: "Vaccinations");

            migrationBuilder.DropTable(
                name: "AppointmentStatusHistory");

            migrationBuilder.DropTable(
                name: "RecommendationRules");

            migrationBuilder.DropTable(
                name: "ServicePricing");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_VeterinarianID",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "Gender",
                table: "Pets");

            migrationBuilder.DropColumn(
                name: "ResultType",
                table: "LabResults");

            migrationBuilder.DropColumn(
                name: "Quantity",
                table: "InvoiceItems");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "VeterinarianID",
                table: "Appointments");

            migrationBuilder.RenameColumn(
                name: "PetID",
                table: "Vaccinations",
                newName: "MedicalRecordId");

            migrationBuilder.RenameIndex(
                name: "IX_Vaccinations_PetID",
                table: "Vaccinations",
                newName: "IX_Vaccinations_MedicalRecordId");

            migrationBuilder.AlterColumn<string>(
                name: "PasswordHash",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AddColumn<bool>(
                name: "IsAppUser",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "DurationMinutes",
                table: "Services",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                table: "Services",
                type: "decimal(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "GenderID",
                table: "Pets",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsRead",
                table: "Notifications",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "LabTestId",
                table: "LabResults",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AppointmentStatusId",
                table: "Appointments",
                type: "int",
                nullable: false,
                defaultValueSql: "((1))");

            migrationBuilder.AddColumn<TimeSpan>(
                name: "Duration",
                table: "Appointments",
                type: "time",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AppointmentStatuses",
                columns: table => new
                {
                    AppointmentStatusId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Appointm__A619B660B6BF8E8D", x => x.AppointmentStatusId);
                });

            migrationBuilder.CreateTable(
                name: "Genders",
                columns: table => new
                {
                    GenderID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Genders__4E24E817524FB169", x => x.GenderID);
                });

            migrationBuilder.CreateTable(
                name: "LabTests",
                columns: table => new
                {
                    LabTestId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    ReferenceRange = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__LabTests__64D339253100BB88", x => x.LabTestId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Pets_GenderID",
                table: "Pets",
                column: "GenderID");

            migrationBuilder.CreateIndex(
                name: "IX_LabResults_LabTestId",
                table: "LabResults",
                column: "LabTestId");

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_AppointmentStatusId",
                table: "Appointments",
                column: "AppointmentStatusId");

            migrationBuilder.CreateIndex(
                name: "UQ__Appointm__737584F67F56CD09",
                table: "AppointmentStatuses",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Genders__737584F6A4CE2C31",
                table: "Genders",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Appointments_Status",
                table: "Appointments",
                column: "AppointmentStatusId",
                principalTable: "AppointmentStatuses",
                principalColumn: "AppointmentStatusId");

            migrationBuilder.AddForeignKey(
                name: "FK_LabResult_LabTest",
                table: "LabResults",
                column: "LabTestId",
                principalTable: "LabTests",
                principalColumn: "LabTestId");

            migrationBuilder.AddForeignKey(
                name: "FK_Pets_GenderID",
                table: "Pets",
                column: "GenderID",
                principalTable: "Genders",
                principalColumn: "GenderID");

            migrationBuilder.AddForeignKey(
                name: "FK_Vaccinations_MedicalRecords",
                table: "Vaccinations",
                column: "MedicalRecordId",
                principalTable: "MedicalRecords",
                principalColumn: "MedicalRecordID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Appointments_Status",
                table: "Appointments");

            migrationBuilder.DropForeignKey(
                name: "FK_LabResult_LabTest",
                table: "LabResults");

            migrationBuilder.DropForeignKey(
                name: "FK_Pets_GenderID",
                table: "Pets");

            migrationBuilder.DropForeignKey(
                name: "FK_Vaccinations_MedicalRecords",
                table: "Vaccinations");

            migrationBuilder.DropTable(
                name: "AppointmentStatuses");

            migrationBuilder.DropTable(
                name: "Genders");

            migrationBuilder.DropTable(
                name: "LabTests");

            migrationBuilder.DropIndex(
                name: "IX_Pets_GenderID",
                table: "Pets");

            migrationBuilder.DropIndex(
                name: "IX_LabResults_LabTestId",
                table: "LabResults");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_AppointmentStatusId",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "IsAppUser",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DurationMinutes",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "Price",
                table: "Services");

            migrationBuilder.DropColumn(
                name: "GenderID",
                table: "Pets");

            migrationBuilder.DropColumn(
                name: "IsRead",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "LabTestId",
                table: "LabResults");

            migrationBuilder.DropColumn(
                name: "AppointmentStatusId",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "Duration",
                table: "Appointments");

            migrationBuilder.RenameColumn(
                name: "MedicalRecordId",
                table: "Vaccinations",
                newName: "PetID");

            migrationBuilder.RenameIndex(
                name: "IX_Vaccinations_MedicalRecordId",
                table: "Vaccinations",
                newName: "IX_Vaccinations_PetID");

            migrationBuilder.AlterColumn<string>(
                name: "PasswordHash",
                table: "Users",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "Services",
                type: "bit",
                nullable: true,
                defaultValueSql: "((1))");

            migrationBuilder.AddColumn<string>(
                name: "Gender",
                table: "Pets",
                type: "nvarchar(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ResultType",
                table: "LabResults",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Quantity",
                table: "InvoiceItems",
                type: "int",
                nullable: true,
                defaultValueSql: "((1))");

            migrationBuilder.AddColumn<string>(
                name: "Status",
                table: "Appointments",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "VeterinarianID",
                table: "Appointments",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "AppointmentStatusHistory",
                columns: table => new
                {
                    StatusHistoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AppointmentID = table.Column<int>(type: "int", nullable: false),
                    ChangedAt = table.Column<DateTime>(type: "datetime", nullable: false, defaultValueSql: "(getdate())"),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Appointm__DB9734B1D31083AA", x => x.StatusHistoryID);
                    table.ForeignKey(
                        name: "FK__Appointme__Appoi__4F7CD00D",
                        column: x => x.AppointmentID,
                        principalTable: "Appointments",
                        principalColumn: "AppointmentID");
                });

            migrationBuilder.CreateTable(
                name: "RecommendationRules",
                columns: table => new
                {
                    RuleID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ConditionText = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    RecommendationText = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recommen__110458C272C03EC2", x => x.RuleID);
                });

            migrationBuilder.CreateTable(
                name: "ServicePricing",
                columns: table => new
                {
                    ServicePricingID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceID = table.Column<int>(type: "int", nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    EffectiveFrom = table.Column<DateTime>(type: "date", nullable: false, defaultValueSql: "(getdate())"),
                    Price = table.Column<decimal>(type: "decimal(10,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ServiceP__506451DE4950F0B7", x => x.ServicePricingID);
                    table.ForeignKey(
                        name: "FK__ServicePr__Servi__5DCAEF64",
                        column: x => x.ServiceID,
                        principalTable: "Services",
                        principalColumn: "ServiceID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_VeterinarianID",
                table: "Appointments",
                column: "VeterinarianID");

            migrationBuilder.CreateIndex(
                name: "IX_AppointmentStatusHistory_AppointmentID",
                table: "AppointmentStatusHistory",
                column: "AppointmentID");

            migrationBuilder.CreateIndex(
                name: "IX_ServicePricing_ServiceID",
                table: "ServicePricing",
                column: "ServiceID");

            migrationBuilder.AddForeignKey(
                name: "FK__Appointme__Veter__4BAC3F29",
                table: "Appointments",
                column: "VeterinarianID",
                principalTable: "Users",
                principalColumn: "UserID");

            migrationBuilder.AddForeignKey(
                name: "FK__Vaccinati__PetID__73BA3083",
                table: "Vaccinations",
                column: "PetID",
                principalTable: "Pets",
                principalColumn: "PetID");
        }
    }
}
