package com.productops.riskengine.algorithm;

import com.productops.riskengine.dto.RiskCalculationRequest;
import com.productops.riskengine.dto.RiskTaskRequest;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class RiskScoreCalculator {
    public Calculation calculate(RiskCalculationRequest request) {
        List<RiskTaskRequest> tasks = request.tasks();
        Set<Long> criticalPath = new HashSet<>(request.criticalPathTaskIds() == null ? List.of() : request.criticalPathTaskIds());
        int blockedHighPriority = (int) tasks.stream().filter(task -> task.blocked() && task.highPriority()).count();
        int overdue = (int) tasks.stream().filter(RiskTaskRequest::overdue).count();
        int highPriorityPending = (int) tasks.stream().filter(task -> task.highPriority() && task.pending()).count();
        int dependencyBlocked = dependencyBlockedCount(tasks);
        int delayedCriticalPath = (int) tasks.stream()
                .filter(task -> criticalPath.contains(task.id()))
                .filter(task -> task.blocked() || task.overdue())
                .count();
        double variancePercent = variancePercent(tasks);

        int score = 0;
        score += Math.min(45, blockedHighPriority * 30);
        score += Math.min(20, overdue * 15);
        score += Math.min(18, (int) Math.round(Math.max(0, variancePercent) / 5));
        score += Math.min(18, delayedCriticalPath * 12);
        score += Math.min(12, highPriorityPending * 4);
        score += Math.min(12, dependencyBlocked * 6);
        score = Math.max(0, Math.min(100, score));

        List<String> reasons = new ArrayList<>();
        if (blockedHighPriority > 0) reasons.add(blockedHighPriority + " high-priority tasks are blocked");
        if (overdue > 0) reasons.add(overdue + " tasks are overdue");
        if (variancePercent > 20) reasons.add("Estimated vs actual effort variance is " + Math.round(variancePercent) + "%");
        if (delayedCriticalPath > 0) reasons.add("Critical path contains delayed tasks");
        if (dependencyBlocked > 0) reasons.add(dependencyBlocked + " tasks depend on blocked predecessors");
        if (reasons.isEmpty()) reasons.add("No major blockers, overdue work, or estimate variance detected");

        List<String> actions = new ArrayList<>();
        if (score >= 66) {
            actions.add("Resolve blockers before deployment approval");
            actions.add("Move release date or reduce sprint scope");
        } else if (score >= 31) {
            actions.add("Review high-priority pending work and dependency order");
            actions.add("Confirm QA and rollback readiness before promotion");
        } else {
            actions.add("Continue monitoring sprint execution and checklist completion");
        }

        return new Calculation(score, riskLevel(score), reasons, actions);
    }

    private int dependencyBlockedCount(List<RiskTaskRequest> tasks) {
        Set<Long> blockedIds = new HashSet<>();
        for (RiskTaskRequest task : tasks) {
            if (task.blocked()) blockedIds.add(task.id());
        }
        int count = 0;
        for (RiskTaskRequest task : tasks) {
            List<Long> dependencies = task.dependencies() == null ? List.of() : task.dependencies();
            if (dependencies.stream().anyMatch(blockedIds::contains)) count++;
        }
        return count;
    }

    private double variancePercent(List<RiskTaskRequest> tasks) {
        double estimate = tasks.stream().mapToDouble(RiskTaskRequest::estimateHours).sum();
        double actual = tasks.stream().mapToDouble(RiskTaskRequest::actualHours).sum();
        if (estimate <= 0) return 0;
        return ((actual - estimate) / estimate) * 100.0;
    }

    private String riskLevel(int score) {
        if (score <= 30) return "LOW";
        if (score <= 65) return "MEDIUM";
        return "HIGH";
    }

    public record Calculation(int score, String level, List<String> reasons, List<String> suggestedActions) {
    }
}
