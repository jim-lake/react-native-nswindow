import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function ColorWindow({ color = '#ff6b6b' }: { color?: string }) {
  console.log('[ColorWindow] Rendering with color:', color);
  return (
    <View style={[styles.container, { backgroundColor: color }]}>
      <Text style={[styles.title, { color: '#fff' }]}>🎨 Color Window</Text>
      <Text style={[styles.subtitle, { color: '#fff' }]}>
        Background: {color}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: { fontSize: 20, fontWeight: 'bold', color: '#000' },
  subtitle: { fontSize: 14, marginTop: 8, opacity: 0.7, color: '#000' },
});
