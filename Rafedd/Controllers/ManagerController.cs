using BLL.ServiceAbstraction;
using Shared.DTOS.Manager;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Rafedd.Authorization;
using Shared.DTOS.AI;
using Shared.DTOS.AnnualTarget;
using Shared.DTOS.Common;
using Shared.DTOS.Dashboard;
using Shared.DTOS.Performance;
using Shared.DTOS.Reports;
using Shared.DTOS.Tasks;
using Shared.Exceptions;
using System.Security.Claims;

namespace Rafedd.Controllers
{
    [ApiController]
    [Route("api/v1/manager")]
    [Authorize(Roles = "Manager,Admin")]
    public class ManagerController : ControllerBase
    {
        private readonly IAnnualTargetService _annualTargetService;
        private readonly IDashboardService _dashboardService;
        private readonly ITaskService _taskService;
        private readonly IReportService _reportService;
        private readonly IPerformanceAnalysisService _performanceAnalysisService;
        private readonly IMonthlyPerformanceAnalysisService _monthlyPerformanceAnalysisService;
        private readonly ITaskAnalysisService _taskAnalysisService;
        private readonly ILogger<ManagerController> _logger;

        public ManagerController(
            IAnnualTargetService annualTargetService,
            IDashboardService dashboardService,
            ITaskService taskService,
            IReportService reportService,
            IPerformanceAnalysisService performanceAnalysisService,
            IMonthlyPerformanceAnalysisService monthlyPerformanceAnalysisService,
            ITaskAnalysisService taskAnalysisService,
            ILogger<ManagerController> logger)
        {
            _annualTargetService = annualTargetService;
            _dashboardService = dashboardService;
            _taskService = taskService;
            _reportService = reportService;
            _performanceAnalysisService = performanceAnalysisService;
            _monthlyPerformanceAnalysisService = monthlyPerformanceAnalysisService;
            _taskAnalysisService = taskAnalysisService;
            _logger = logger;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) 
                ?? throw new UnauthorizedException("User ID not found in token");
        }

        // Annual Targets
        [HttpPost("annual-targets")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<AnnualTargetResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<AnnualTargetResponseDto>), 400)]
        public async Task<ActionResult<ApiResponse<AnnualTargetResponseDto>>> CreateAnnualTarget([FromBody] CreateAnnualTargetDto dto)
        {
            try
            {
                var managerUserId = GetUserId();
                var result = await _annualTargetService.CreateAnnualTargetAsync(managerUserId, dto);
                return Ok(ApiResponse<AnnualTargetResponseDto>.SuccessResponse(result, "تم إنشاء الهدف السنوي بنجاح. تم توليد الخطة الكاملة (48 أسبوع) باستخدام Gemini AI"));
            }
            catch (InvalidOperationException ex)
            {
                throw new BadRequestException(ex.Message);
            }
        }

        [HttpGet("annual-targets/{year}")]
        [ProducesResponseType(typeof(ApiResponse<AnnualTargetResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<AnnualTargetResponseDto>), 404)]
        public async Task<ActionResult<ApiResponse<AnnualTargetResponseDto>>> GetAnnualTargetByYear(int year)
        {
            try
            {
                var managerUserId = GetUserId();
                var result = await _annualTargetService.GetAnnualTargetByYearAsync(managerUserId, year);
                
                if (result == null)
                {
                    throw new NotFoundException($"الهدف السنوي للعام {year} غير موجود");
                }

                return Ok(ApiResponse<AnnualTargetResponseDto>.SuccessResponse(result, "تم الحصول على الهدف السنوي بنجاح"));
            }
            catch (NotFoundException)
            {
                throw;
            }
        }

        [HttpGet("annual-targets")]
        [ProducesResponseType(typeof(ApiResponse<List<AnnualTargetResponseDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<AnnualTargetResponseDto>>>> GetAllAnnualTargets()
        {
            var managerUserId = GetUserId();
            var result = await _annualTargetService.GetAllAnnualTargetsAsync(managerUserId);
            return Ok(ApiResponse<List<AnnualTargetResponseDto>>.SuccessResponse(result, "تم الحصول على الأهداف السنوية بنجاح"));
        }

        // Dashboard
        [HttpGet("dashboard")]
        [ProducesResponseType(typeof(ApiResponse<ManagerDashboardDto>), 200)]
        public async Task<ActionResult<ApiResponse<ManagerDashboardDto>>> GetDashboard()
        {
            var managerUserId = GetUserId();
            var result = await _dashboardService.GetManagerDashboardAsync(managerUserId);
            return Ok(ApiResponse<ManagerDashboardDto>.SuccessResponse(result, "تم الحصول على لوحة التحكم بنجاح"));
        }

        // Tasks
        [HttpPost("tasks")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<TaskDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<TaskDto>), 400)]
        public async Task<ActionResult<ApiResponse<TaskDto>>> CreateTask([FromBody] CreateTaskDto dto)
        {
            try
            {
                var managerUserId = GetUserId();
                var result = await _taskService.CreateTaskAsync(managerUserId, dto);
                return Ok(ApiResponse<TaskDto>.SuccessResponse(result, "تم إنشاء المهمة بنجاح"));
            }
            catch (InvalidOperationException ex)
            {
                throw new BadRequestException(ex.Message);
            }
        }

        [HttpGet("tasks")]
        [ProducesResponseType(typeof(ApiResponse<List<TaskDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<TaskDto>>>> GetTasksByWeek(
            [FromQuery] int year,
            [FromQuery] int month,
            [FromQuery] int weekNumber)
        {
            var managerUserId = GetUserId();
            var result = await _taskService.GetTasksByWeekAsync(managerUserId, year, month, weekNumber);
            return Ok(ApiResponse<List<TaskDto>>.SuccessResponse(result, $"تم الحصول على مهام الأسبوع {weekNumber} من الشهر {month} بنجاح"));
        }

        [HttpDelete("tasks/{taskId}")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse), 200)]
        [ProducesResponseType(typeof(ApiResponse), 404)]
        public async Task<ActionResult<ApiResponse>> DeleteTask(int taskId)
        {
            try
            {
                var managerUserId = GetUserId();
                var result = await _taskService.DeleteTaskAsync(taskId, managerUserId);
                
                if (!result)
                {
                    throw new NotFoundException("المهمة غير موجودة");
                }

                return Ok(ApiResponse.SuccessResponse("تم حذف المهمة بنجاح"));
            }
            catch (NotFoundException)
            {
                throw;
            }
        }

        // Reports
        [HttpGet("reports")]
        [ProducesResponseType(typeof(ApiResponse<List<TaskReportDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<TaskReportDto>>>> GetReportsByWeek(
            [FromQuery] int year,
            [FromQuery] int month,
            [FromQuery] int weekNumber)
        {
            var managerUserId = GetUserId();
            var result = await _reportService.GetReportsByWeekAsync(managerUserId, year, month, weekNumber);
            return Ok(ApiResponse<List<TaskReportDto>>.SuccessResponse(result, $"تم الحصول على تقارير الأسبوع {weekNumber} من الشهر {month} بنجاح"));
        }

        // Performance Reports
        [HttpGet("performance-reports/{weeklyPlanId}")]
        [ProducesResponseType(typeof(ApiResponse<PerformanceReportDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<PerformanceReportDto>), 404)]
        public async Task<ActionResult<ApiResponse<PerformanceReportDto>>> GetPerformanceReport(int weeklyPlanId)
        {
            try
            {
                var result = await _performanceAnalysisService.GetPerformanceReportAsync(weeklyPlanId);
                
                if (result == null)
                {
                    throw new NotFoundException("تقرير الأداء غير موجود");
                }

                return Ok(ApiResponse<PerformanceReportDto>.SuccessResponse(result, "تم الحصول على تقرير الأداء بنجاح"));
            }
            catch (NotFoundException)
            {
                throw;
            }
        }

        [HttpPost("performance-reports/{weeklyPlanId}/generate")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<PerformanceReportDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<PerformanceReportDto>), 400)]
        public async Task<ActionResult<ApiResponse<PerformanceReportDto>>> GeneratePerformanceReport(int weeklyPlanId)
        {
            try
            {
                var result = await _performanceAnalysisService.GenerateWeeklyPerformanceReportAsync(weeklyPlanId);
                return Ok(ApiResponse<PerformanceReportDto>.SuccessResponse(result, "تم توليد تقرير الأداء بنجاح باستخدام Gemini AI"));
            }
            catch (InvalidOperationException ex)
            {
                throw new BadRequestException(ex.Message);
            }
        }

        [HttpGet("performance-reports")]
        [ProducesResponseType(typeof(ApiResponse<List<PerformanceReportDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<PerformanceReportDto>>>> GetPerformanceReportsByYear([FromQuery] int year)
        {
            var managerUserId = GetUserId();
            var result = await _performanceAnalysisService.GetPerformanceReportsByYearAsync(managerUserId, year);
            return Ok(ApiResponse<List<PerformanceReportDto>>.SuccessResponse(result, $"تم الحصول على تقارير الأداء للعام {year} بنجاح"));
        }

        // Task Analysis (AI)
        [HttpPost("tasks/{taskId}/analyze")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<TaskAnalysisResultDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<TaskAnalysisResultDto>), 404)]
        [ProducesResponseType(typeof(ApiResponse<TaskAnalysisResultDto>), 403)]
        public async Task<ActionResult<ApiResponse<TaskAnalysisResultDto>>> AnalyzeTask(int taskId)
        {
            try
            {
                var managerUserId = GetUserId();
                var result = await _taskAnalysisService.AnalyzeTaskAsync(taskId, managerUserId);
                return Ok(ApiResponse<TaskAnalysisResultDto>.SuccessResponse(result, "تم تحليل المهمة بنجاح باستخدام Gemini AI"));
            }
            catch (NotFoundException)
            {
                throw;
            }
            catch (UnauthorizedAccessException ex)
            {
                throw new ForbiddenException(ex.Message);
            }
        }

        [HttpPost("tasks/analyze-batch")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<List<TaskAnalysisResultDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<TaskAnalysisResultDto>>>> AnalyzeBatchTasks([FromBody] List<int> taskIds)
        {
            var managerUserId = GetUserId();
            var result = await _taskAnalysisService.AnalyzeBatchTasksAsync(taskIds, managerUserId);

            var successCount = result.Count;
            var message = successCount > 0
                ? $"تم تحليل {successCount} مهمة بنجاح باستخدام Gemini AI"
                : "لم يتم العثور على مهام صالحة للتحليل";

            return Ok(ApiResponse<List<TaskAnalysisResultDto>>.SuccessResponse(result, message));
        }

        // Monthly Performance Reports
        [HttpPost("monthly-reports/{monthlyPlanId}/generate")]
        [RequireActiveSubscription]
        [ProducesResponseType(typeof(ApiResponse<MonthlyPerformanceReportDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<MonthlyPerformanceReportDto>), 400)]
        public async Task<ActionResult<ApiResponse<MonthlyPerformanceReportDto>>> GenerateMonthlyReport(int monthlyPlanId)
        {
            try
            {
                var result = await _monthlyPerformanceAnalysisService.GenerateMonthlyPerformanceReportAsync(monthlyPlanId);
                return Ok(ApiResponse<MonthlyPerformanceReportDto>.SuccessResponse(result, "تم توليد تقرير الأداء الشهري بنجاح باستخدام Gemini AI"));
            }
            catch (InvalidOperationException ex)
            {
                throw new BadRequestException(ex.Message);
            }
        }

        [HttpGet("monthly-reports/{monthlyPlanId}")]
        [ProducesResponseType(typeof(ApiResponse<MonthlyPerformanceReportDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<MonthlyPerformanceReportDto>), 404)]
        public async Task<ActionResult<ApiResponse<MonthlyPerformanceReportDto>>> GetMonthlyReport(int monthlyPlanId)
        {
            try
            {
                var result = await _monthlyPerformanceAnalysisService.GetMonthlyReportAsync(monthlyPlanId);

                if (result == null)
                {
                    throw new NotFoundException("تقرير الأداء الشهري غير موجود");
                }

                return Ok(ApiResponse<MonthlyPerformanceReportDto>.SuccessResponse(result, "تم الحصول على تقرير الأداء الشهري بنجاح"));
            }
            catch (NotFoundException)
            {
                throw;
            }
        }

        [HttpGet("monthly-reports")]
        [ProducesResponseType(typeof(ApiResponse<List<MonthlyPerformanceReportDto>>), 200)]
        public async Task<ActionResult<ApiResponse<List<MonthlyPerformanceReportDto>>>> GetMonthlyReportsByYear([FromQuery] int year)
        {
            var managerUserId = GetUserId();
            var result = await _monthlyPerformanceAnalysisService.GetMonthlyReportsByYearAsync(managerUserId, year);
            return Ok(ApiResponse<List<MonthlyPerformanceReportDto>>.SuccessResponse(result, $"تم الحصول على تقارير الأداء الشهرية للعام {year} بنجاح"));
        }

        // Manager Settings
        [HttpGet("settings")]
        [ProducesResponseType(typeof(ApiResponse<ManagerSettingsDto>), 200)]
        public ActionResult<ApiResponse<ManagerSettingsDto>> GetSettings()
        {
            // For now, return default settings
            // In future, these should be stored in database per manager
            var settings = new ManagerSettingsDto
            {
                Notifications = new NotificationPreferences
                {
                    EmailOnTaskReport = true,
                    EmailOnEmployeeJoin = true,
                    EmailOnTaskDeadline = true,
                    EmailOnWeeklyReport = true
                },
                Dashboard = new DashboardPreferences
                {
                    DefaultView = "overview",
                    ShowWeeklyStats = true,
                    ShowMonthlyStats = true,
                    ShowEmployeePerformance = true
                },
                Company = new CompanyPreferences
                {
                    WorkingHoursStart = "09:00",
                    WorkingHoursEnd = "17:00",
                    WeekStartDay = DayOfWeek.Sunday,
                    TimeZone = "Arab Standard Time"
                }
            };

            return Ok(ApiResponse<ManagerSettingsDto>.SuccessResponse(settings, "تم الحصول على إعدادات المدير بنجاح"));
        }

        [HttpPut("settings")]
        [ProducesResponseType(typeof(ApiResponse<ManagerSettingsDto>), 200)]
        public ActionResult<ApiResponse<ManagerSettingsDto>> UpdateSettings([FromBody] ManagerSettingsDto settings)
        {
            // For now, just return the same settings
            // In future, save to database
            _logger.LogInformation("Manager settings updated (not persisted yet - requires database schema)");

            return Ok(ApiResponse<ManagerSettingsDto>.SuccessResponse(settings, "تم تحديث إعدادات المدير بنجاح"));
        }
    }
}
