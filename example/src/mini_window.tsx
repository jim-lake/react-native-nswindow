import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function MiniWindow() {
  console.log('[MiniWindow] Rendering');
  return (
    <View style={[styles.container, { backgroundColor: '#2d3436' }]}>
      <Text style={[styles.title, { color: '#fff' }]}>🔲 Mini</Text>
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
});
