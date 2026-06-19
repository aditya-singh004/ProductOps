package com.productops.riskengine.service;

import com.productops.riskengine.algorithm.RiskScoreCalculator;
import com.productops.riskengine.dto.RiskCalculationRequest;
import com.productops.riskengine.dto.RiskCalculationResponse;
import org.springframework.stereotype.Service;

@Service
public class RiskCalculationService {
    private final RiskScoreCalculator calculator = new RiskScoreCalculator();

    public RiskCalculationResponse calculate(RiskCalculationRequest request) {
        RiskScoreCalculator.Calculation calculation = calculator.calculate(request);
        return new RiskCalculationResponse(
                calculation.score(),
                calculation.level(),
                calculation.reasons(),
                calculation.suggestedActions()
        );
    }
}
