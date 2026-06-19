package com.productops.riskengine;

import com.productops.riskengine.dto.RiskCalculationRequest;
import com.productops.riskengine.dto.RiskCalculationResponse;
import com.productops.riskengine.dto.RiskTaskRequest;
import com.productops.riskengine.service.RiskCalculationService;
import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class RiskCalculationServiceTest {
    private final RiskCalculationService service = new RiskCalculationService();

    @Test
    void returnsHighRiskForBlockedHighPriorityAndCriticalPathDelay() {
        RiskCalculationResponse response = service.calculate(new RiskCalculationRequest(
                12L,
                4L,
                List.of(1L, 2L),
                List.of(
                        new RiskTaskRequest(1L, "Create DB migration", 8, 12, "IN_PROGRESS", "HIGH", false, true, List.of()),
                        new RiskTaskRequest(2L, "Build backend API", 6, 0, "TODO", "HIGH", true, false, List.of(1L))
                )
        ));

        assertEquals("HIGH", response.riskLevel());
        assertTrue(response.riskScore() >= 66);
        assertTrue(response.reasons().stream().anyMatch(reason -> reason.contains("high-priority")));
    }

    @Test
    void returnsLowRiskForCleanCompletedWork() {
        RiskCalculationResponse response = service.calculate(new RiskCalculationRequest(
                1L,
                null,
                List.of(1L),
                List.of(new RiskTaskRequest(1L, "Done", 4, 4, "DONE", "MEDIUM", false, false, List.of()))
        ));

        assertEquals("LOW", response.riskLevel());
        assertTrue(response.riskScore() <= 30);
    }

    @Test
    void mediumRiskForOverdueWorkAndVariance() {
        RiskCalculationResponse response = service.calculate(new RiskCalculationRequest(
                1L,
                null,
                List.of(),
                List.of(new RiskTaskRequest(1L, "Late", 4, 8, "IN_PROGRESS", "MEDIUM", false, true, List.of()))
        ));

        assertEquals("MEDIUM", response.riskLevel());
        assertTrue(response.reasons().stream().anyMatch(reason -> reason.contains("variance")));
    }
}
