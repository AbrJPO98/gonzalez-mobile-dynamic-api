import { NextRequest, NextResponse } from "next/server";
import { verifyAccessToken } from "./verifyToken";
import { verifyTokenFromBody } from "./verifyTokenFromBody";

export const parseBoolean = (value: string | null | undefined, defaultValue = false): boolean => {
    if (value == null) return defaultValue;
    const v = String(value).trim().toLowerCase();
    return v === "1" || v === "true" || v === "yes";
};

export const validateDynamicFilesAccess = (
    req: NextRequest,
    mobileAccessTokenRaw?: string,
    tokenFromBodyOrQuery?: string,
    shouldVerifyAccessToken = true,
): NextResponse | null => {
    const expectedMobileToken = process.env.MOBILE_ACCESS_TOKEN?.trim();
    const incomingMobileToken = String(
        mobileAccessTokenRaw || req.headers.get("x-mobile-access-token") || "",
    ).trim();

    if (!expectedMobileToken) {
        return NextResponse.json(
            { status: false, message: "MOBILE_ACCESS_TOKEN no configurado en el servidor" },
            { status: 500 },
        );
    }
    if (!incomingMobileToken) {
        return NextResponse.json(
            { status: false, message: "mobileAccessToken es obligatorio" },
            { status: 403 },
        );
    }
    if (incomingMobileToken !== expectedMobileToken) {
        return NextResponse.json(
            { status: false, message: "mobileAccessToken inválido" },
            { status: 403 },
        );
    }

    const tokenValidationHeader = verifyAccessToken(req);
    const tokenValidationAlt = verifyTokenFromBody(tokenFromBodyOrQuery);
    const tokenValidation = tokenValidationHeader.valid ? tokenValidationHeader : tokenValidationAlt;

    if (shouldVerifyAccessToken && !tokenValidation.valid) {
        return NextResponse.json(
            { status: false, expired: tokenValidation.expired, message: tokenValidation.message },
            { status: tokenValidation.expired ? 401 : 403 },
        );
    }

    return null;
};
