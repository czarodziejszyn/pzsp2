import math

def angle_between_points(p1, p2):
    """Oblicz kąt linii p1->p2 względem osi poziomej (podłoża), w stopniach."""
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    angle = math.degrees(math.atan2(dy, dx))
    return angle

def angle_between_vectors(v1, v2):
    """Oblicz kąt między dwoma wektorami w stopniach."""
    dot = v1[0]*v2[0] + v1[1]*v2[1]
    mag1 = math.sqrt(v1[0]**2 + v1[1]**2)
    mag2 = math.sqrt(v2[0]**2 + v2[1]**2)
    if mag1 == 0 or mag2 == 0:
        return 0
    cos_angle = dot / (mag1 * mag2)
    cos_angle = max(min(cos_angle, 1), -1)  # ograniczenie do [-1,1]
    angle = math.degrees(math.acos(cos_angle))
    return angle

def vector(p1, p2):
    return (p2[0]-p1[0], p2[1]-p1[1])

def average_point(points):
    x = sum(p[0] for p in points)/len(points)
    y = sum(p[1] for p in points)/len(points)
    return (x, y)

def pose_angle_score(pose1, pose2):
    """
    pose1 i pose2: listy punktów [(x,y), ...] w ustalonej kolejności:
    right ear, left ear, right shoulder, left shoulder, right elbow, left elbow,
    right wrist, right wrist, right hip, left hip, right knee, left knee,
    right ankle, left ankle
    """

    # indeksy punktów (0-based)
    R_EAR, L_EAR = 0, 1
    R_SHOULDER, L_SHOULDER = 2, 3
    R_ELBOW, L_ELBOW = 4, 5
    R_WRIST, L_WRIST = 6, 7
    R_HIP, L_HIP = 8, 9
    R_KNEE, L_KNEE = 10, 11
    R_ANKLE, L_ANKLE = 12, 13

    # 1. Kąt głowy względem barków (średnia punktów uszu względem średniej barków)
    head_center1 = average_point([pose1[R_EAR], pose1[L_EAR]])
    shoulders_center1 = average_point([pose1[R_SHOULDER], pose1[L_SHOULDER]])
    angle_head1 = angle_between_points(shoulders_center1, head_center1)

    head_center2 = average_point([pose2[R_EAR], pose2[L_EAR]])
    shoulders_center2 = average_point([pose2[R_SHOULDER], pose2[L_SHOULDER]])
    angle_head2 = angle_between_points(shoulders_center2, head_center2)

    # 2. Linia barków - odniesienie = 180 stopni (pozioma)
    # Obliczamy kąt linii barków względem poziomu
    def shoulder_angle(pose):
        return angle_between_points(pose[R_SHOULDER], pose[L_SHOULDER])
    angle_shoulders1 = shoulder_angle(pose1)
    angle_shoulders2 = shoulder_angle(pose2)

    # korekta - traktujemy linie barków jako 180 stopni (poziom)
    # przekształcimy wszystkie kąty, odejmując kąt barków aby znormalizować
    norm_head1 = angle_head1 - angle_shoulders1 + 180
    norm_head2 = angle_head2 - angle_shoulders2 + 180

    # 3. Linia bioder względem barków
    hip_line1 = angle_between_points(pose1[R_HIP], pose1[L_HIP]) - angle_shoulders1 + 180
    hip_line2 = angle_between_points(pose2[R_HIP], pose2[L_HIP]) - angle_shoulders2 + 180

    # 4. Kąt kolan (pomiędzy łydką a udem)
    def knee_angle(pose, knee_idx, hip_idx, ankle_idx):
        thigh = vector(pose[hip_idx], pose[knee_idx])
        calf = vector(pose[ankle_idx], pose[knee_idx])
        return angle_between_vectors(thigh, calf)

    knee_angle1_r = knee_angle(pose1, R_KNEE, R_HIP, R_ANKLE)
    knee_angle2_r = knee_angle(pose2, R_KNEE, R_HIP, R_ANKLE)

    knee_angle1_l = knee_angle(pose1, L_KNEE, L_HIP, L_ANKLE)
    knee_angle2_l = knee_angle(pose2, L_KNEE, L_HIP, L_ANKLE)

    # 5. Kąt uda (pomiędzy biodrem a kolanem i barkami)
    def thigh_angle(pose, hip_idx, knee_idx, shoulders_center):
        thigh = vector(pose[hip_idx], pose[knee_idx])
        spine = vector(shoulders_center, pose[hip_idx])
        return angle_between_vectors(thigh, spine)

    thigh_angle1_r = thigh_angle(pose1, R_HIP, R_KNEE, shoulders_center1)
    thigh_angle2_r = thigh_angle(pose2, R_HIP, R_KNEE, shoulders_center2)

    thigh_angle1_l = thigh_angle(pose1, L_HIP, L_KNEE, shoulders_center1)
    thigh_angle2_l = thigh_angle(pose2, L_HIP, L_KNEE, shoulders_center2)

    # 6. Kąt łokcia (biceps - przedramię)
    def elbow_angle(pose, shoulder_idx, elbow_idx, wrist_idx):
        upper_arm = vector(pose[shoulder_idx], pose[elbow_idx])
        lower_arm = vector(pose[wrist_idx], pose[elbow_idx])
        return angle_between_vectors(upper_arm, lower_arm)

    elbow_angle1_r = elbow_angle(pose1, R_SHOULDER, R_ELBOW, R_WRIST)
    elbow_angle2_r = elbow_angle(pose2, R_SHOULDER, R_ELBOW, R_WRIST)

    elbow_angle1_l = elbow_angle(pose1, L_SHOULDER, L_ELBOW, L_WRIST)
    elbow_angle2_l = elbow_angle(pose2, L_SHOULDER, L_ELBOW, L_WRIST)

    # 7. Kąt ręki (pomiędzy barkiem a bicepsem)
    def upper_arm_angle(pose, shoulder_idx, elbow_idx):
        return angle_between_points(pose[shoulder_idx], pose[elbow_idx])

    upper_arm_angle1_r = upper_arm_angle(pose1, R_SHOULDER, R_ELBOW)
    upper_arm_angle2_r = upper_arm_angle(pose2, R_SHOULDER, R_ELBOW)

    upper_arm_angle1_l = upper_arm_angle(pose1, L_SHOULDER, L_ELBOW)
    upper_arm_angle2_l = upper_arm_angle(pose2, L_SHOULDER, L_ELBOW)

    # 8. Kąt kręgosłupa (średnia barków do średnia bioder)
    spine1_start = shoulders_center1
    spine1_end = average_point([pose1[R_HIP], pose1[L_HIP]])
    spine2_start = shoulders_center2
    spine2_end = average_point([pose2[R_HIP], pose2[L_HIP]])

    spine_angle1 = angle_between_points(spine1_start, spine1_end) - angle_shoulders1 + 180
    spine_angle2 = angle_between_points(spine2_start, spine2_end) - angle_shoulders2 + 180

    # różnice kątów
    angles1 = [
        norm_head1,
        180,  # linia barków - normalizowana do 180
        hip_line1,
        knee_angle1_r,
        knee_angle1_l,
        thigh_angle1_r,
        thigh_angle1_l,
        elbow_angle1_r,
        elbow_angle1_l,
        upper_arm_angle1_r,
        upper_arm_angle1_l,
        spine_angle1,
    ]
    angles2 = [
        norm_head2,
        180,
        hip_line2,
        knee_angle2_r,
        knee_angle2_l,
        thigh_angle2_r,
        thigh_angle2_l,
        elbow_angle2_r,
        elbow_angle2_l,
        upper_arm_angle2_r,
        upper_arm_angle2_l,
        spine_angle2,
    ]

    def angle_diff(a1, a2):
        diff = abs(a1 - a2) % 360
        if diff > 180:
            diff = 360 - diff
        return diff

    diffs = [angle_diff(a1, a2) for a1, a2 in zip(angles1, angles2)]
    max_angle = 180
    # im większe k, tym większa różnica między podobnymi i odległymi

    k = 750
    scores = [math.exp(-k * (d / max_angle)**2) for d in diffs]
    
    return sum(scores) / len(scores)
