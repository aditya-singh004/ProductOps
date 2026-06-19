package com.productops.riskengine.controller;

import com.productops.riskengine.dto.RiskCalculationRequest;
import com.productops.riskengine.dto.RiskCalculationResponse;
import com.productops.riskengine.service.RiskCalculationService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/risk")
public class RiskController {
    private final RiskCalculationService service;

    public RiskController(RiskCalculationService service) {
        this.service = service;
    }

    @PostMapping("/calculate")
    public RiskCalculationResponse calculate(@Valid @RequestBody RiskCalculationRequest request) {
        return service.calculate(request);
    }
}
