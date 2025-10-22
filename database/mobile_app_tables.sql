-- ========================================
-- НОВЫЕ ТАБЛИЦЫ ДЛЯ МОБИЛЬНОГО ПРИЛОЖЕНИЯ
-- ========================================

-- Таблица сообщений между водителями и диспетчерами
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id TEXT NOT NULL,
  receiver_id TEXT,
  content TEXT NOT NULL,
  type TEXT CHECK (type IN ('text', 'image', 'location', 'system')) DEFAULT 'text',
  attachment_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица уведомлений
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT CHECK (type IN ('route_assigned', 'delivery_reminder', 'message', 'system')) NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица настроек водителя
CREATE TABLE IF NOT EXISTS driver_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE UNIQUE,
  notifications_enabled BOOLEAN DEFAULT true,
  gps_tracking_enabled BOOLEAN DEFAULT true,
  auto_accept_routes BOOLEAN DEFAULT false,
  preferred_language TEXT DEFAULT 'ru',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица фото доставок
CREATE TABLE IF NOT EXISTS delivery_photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  stop_id UUID REFERENCES stops(id) ON DELETE CASCADE,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  photo_type TEXT CHECK (photo_type IN ('delivery', 'issue', 'signature')) DEFAULT 'delivery',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Таблица статусов водителей (расширенная)
CREATE TABLE IF NOT EXISTS driver_status_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  location_lat DOUBLE PRECISION,
  location_lon DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ========================================

CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_driver_id ON notifications(driver_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at);
CREATE INDEX IF NOT EXISTS idx_delivery_photos_stop_id ON delivery_photos(stop_id);
CREATE INDEX IF NOT EXISTS idx_driver_status_log_driver_id ON driver_status_log(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_status_log_created_at ON driver_status_log(created_at);

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_status_log ENABLE ROW LEVEL SECURITY;

-- ========================================
-- ПОЛИТИКИ БЕЗОПАСНОСТИ
-- ========================================

-- Политики для сообщений
CREATE POLICY "Drivers can view their messages" ON messages
  FOR SELECT USING (
    sender_id IN (
      SELECT id::text FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    ) OR receiver_id IN (
      SELECT id::text FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    ) OR receiver_id IS NULL
  );

CREATE POLICY "Drivers can send messages" ON messages
  FOR INSERT WITH CHECK (
    sender_id IN (
      SELECT id::text FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    )
  );

CREATE POLICY "Admins can send messages to drivers" ON messages
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated'
  );

-- Политики для уведомлений
CREATE POLICY "Drivers can view their notifications" ON notifications
  FOR SELECT USING (
    driver_id IN (
      SELECT id FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    )
  );

CREATE POLICY "Admins can create notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Политики для настроек
CREATE POLICY "Drivers can manage their settings" ON driver_settings
  FOR ALL USING (
    driver_id IN (
      SELECT id FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    )
  );

-- Политики для фото доставок
CREATE POLICY "Drivers can manage their delivery photos" ON delivery_photos
  FOR ALL USING (
    driver_id IN (
      SELECT id FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    )
  );

-- Политики для лога статусов
CREATE POLICY "Drivers can create status logs" ON driver_status_log
  FOR INSERT WITH CHECK (
    driver_id IN (
      SELECT id FROM drivers WHERE phone = auth.jwt() ->> 'phone'
    )
  );

-- ========================================
-- REALTIME ПОДПИСКИ
-- ========================================

-- Включаем Realtime для новых таблиц
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE driver_settings;
ALTER PUBLICATION supabase_realtime ADD TABLE delivery_photos;
ALTER PUBLICATION supabase_realtime ADD TABLE driver_status_log;

-- ========================================
-- ФУНКЦИИ И ТРИГГЕРЫ
-- ========================================

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггеры для обновления updated_at
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_driver_settings_updated_at BEFORE UPDATE ON driver_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- ТЕСТОВЫЕ ДАННЫЕ (ОПЦИОНАЛЬНО)
-- ========================================

-- Вставка тестовых настроек для существующих водителей
INSERT INTO driver_settings (driver_id, notifications_enabled, gps_tracking_enabled)
SELECT id, true, true
FROM drivers
WHERE id NOT IN (SELECT driver_id FROM driver_settings);

-- ========================================
-- КОММЕНТАРИИ К ТАБЛИЦАМ
-- ========================================

COMMENT ON TABLE messages IS 'Сообщения между водителями и диспетчерами';
COMMENT ON TABLE notifications IS 'Уведомления для водителей';
COMMENT ON TABLE driver_settings IS 'Настройки водителей';
COMMENT ON TABLE delivery_photos IS 'Фотографии доставок';
COMMENT ON TABLE driver_status_log IS 'Лог статусов и локаций водителей';

COMMENT ON COLUMN messages.sender_id IS 'ID отправителя (может быть ID водителя или admin)';
COMMENT ON COLUMN messages.receiver_id IS 'ID получателя (null для сообщений всем водителям)';
COMMENT ON COLUMN messages.type IS 'Тип сообщения: text, image, location, system';
COMMENT ON COLUMN notifications.type IS 'Тип уведомления: route_assigned, delivery_reminder, message, system';
COMMENT ON COLUMN delivery_photos.photo_type IS 'Тип фото: delivery, issue, signature';
