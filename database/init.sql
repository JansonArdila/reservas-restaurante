-- Crear base de datos (ejecutar esto manualmente en psql primero)
-- CREATE DATABASE restaurant_reservations;

-- Conectarse a la base de datos y ejecutar:

-- Tabla de reservas
CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20),
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INTEGER NOT NULL CHECK (party_size > 0),
    table_number VARCHAR(10),
    special_requests TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(reservation_date);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);

-- Datos de ejemplo
INSERT INTO reservations (customer_name, customer_email, customer_phone, reservation_date, reservation_time, party_size, table_number, special_requests, status) VALUES
('Juan Pérez', 'juan@email.com', '+1234567890', '2024-01-15', '19:00:00', 2, 'Mesa-1', 'Sin gluten', 'confirmed'),
('María García', 'maria@email.com', '+1234567891', '2024-01-15', '20:30:00', 4, 'Mesa-4', 'Celebración de cumpleaños', 'pending'),
('Carlos López', 'carlos@email.com', '+1234567892', '2024-01-16', '21:00:00', 3, 'Mesa-2', '', 'confirmed')
ON CONFLICT DO NOTHING;

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para updated_at
CREATE TRIGGER update_reservations_updated_at 
    BEFORE UPDATE ON reservations 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();