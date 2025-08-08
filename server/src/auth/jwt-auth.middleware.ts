// src/auth/jwt-auth.middleware.ts
import { Injectable, NestMiddleware, UnauthorizedException } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@Injectable()
//valida el token JWT en Authorization para proteger rutas, y en caso de éxito añade el usuario al request
export class JwtAuthMiddleware implements NestMiddleware {
  use(req: any, res: any, next: () => void) {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      throw new UnauthorizedException('Token no proporcionado');
    }

    const [, token] = authHeader.split(' ');

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string; email: string };
      req.user = { id: decoded.sub };
      next();
    } catch (err) {
      throw new UnauthorizedException('Token inválido o expirado');
    }
  }
}
